"""Independent enumeration oracle. Python 3.8+, standard library only.

No MoonRQA algorithm, external source or reference fixtures are imported.
Black runs are grouped by entire diagonals/columns, unlike the cell-start scanner.
All ternary shapes 1x1 through 3x3 and 384 metric/trajectory cases are checked.
"""
import argparse, collections, hashlib, json, math, os, subprocess, sys
from pathlib import Path


def histogram(lines, size):
    result = [0] * (size + 1)
    for line in lines:
        groups = []
        for value in line:
            if value == 1:
                if not groups or groups[-1][0] != 1:
                    groups.append([1, 0])
                groups[-1][1] += 1
            else:
                groups.append([value, 0])
        for value, length in groups:
            if value == 1:
                result[length] += 1
    return result


def expected_matrix(rows):
    n, m = len(rows), len(rows[0])
    diagonals = collections.defaultdict(list)
    for i, row in enumerate(rows):
        for j, value in enumerate(row):
            diagonals[j-i].append(value)
    columns = list(zip(*rows))
    d = histogram(diagonals.values(), min(n, m))
    v = histogram(columns, n)
    h = histogram(rows, m)
    w = [0] * (n + 1)
    # Pair consecutive black positions. A censored interval cannot contain -1.
    for column in columns:
        black = [i for i, x in enumerate(column) if x == 1]
        for start, end in zip(black, black[1:]):
            inside = column[start+1:end]
            if inside and all(x == 0 for x in inside):
                w[len(inside)] += 1
    return d, v, h, w


def line_stats(hist, minimum):
    counts = {k: count for k, count in enumerate(hist) if k >= minimum and count}
    lines = sum(counts.values())
    points = sum(k*v for k, v in counts.items())
    mean = points / lines if lines else None
    entropy = -sum((v/lines)*math.log(v/lines) for v in counts.values())
    return points, mean, max(counts, default=0), entropy


def expected_summary(rows, d, v, w, minimum):
    black = sum(x == 1 for row in rows for x in row)
    eligible = sum(x != -1 for row in rows for x in row)
    dp, dm, dl, de = line_stats(d, minimum)
    vp, vm, vl, ve = line_stats(v, minimum)
    return dict(recurrent=black, eligible=eligible,
                recurrence_rate=black/eligible if eligible else None,
                determinism=dp/black if black else 0.0,
                laminarity=vp/black if black else 0.0,
                mean_diagonal=dm, longest_diagonal=dl,
                divergence=1/dl if dl else None, diagonal_entropy=de,
                trapping_time=vm, longest_vertical=vl, vertical_entropy=ve,
                mean_return_gap=line_stats(w, 1)[1])


def compare(actual, expected, context):
    if isinstance(expected, dict):
        assert actual.keys() == expected.keys(), context
        for key in expected:
            compare(actual[key], expected[key], context + '/' + str(key))
    elif isinstance(expected, list):
        assert len(actual) == len(expected), context
        for i, (a, e) in enumerate(zip(actual, expected)):
            compare(a, e, context + '/' + str(i))
    elif isinstance(expected, float):
        assert isinstance(actual, (int, float)) and math.isfinite(actual), context
        assert math.isclose(actual, expected, rel_tol=1e-12, abs_tol=1e-12), (context, actual, expected)
    else:
        assert actual == expected, (context, actual, expected)


def distance(a, b, metric):
    deltas = [abs(x-y) for x, y in zip(a, b)]
    return [max(deltas), sum(deltas), math.sqrt(sum(d*d for d in deltas))][metric]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--target', default='wasm-gc')
    parser.add_argument('--report')
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    cmd = [os.environ.get('MOON', 'moon'), 'run', 'tools/oracle', '--target', args.target]
    result = subprocess.run(cmd, cwd=root, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if result.returncode:
        sys.stderr.write(result.stderr.decode('utf-8', 'replace'))
        raise SystemExit(result.returncode)
    matrix_cases = metric_cases = 0
    for line in result.stdout.splitlines():
        if not line.strip():
            continue
        item = json.loads(line)
        if item['kind'] == 'matrix':
            n, m, code = item['n'], item['m'], item['code']
            rows = [[(code // (3**(i*m+j))) % 3-1 for j in range(m)] for i in range(n)]
            d, v, h, w = expected_matrix(rows)
            for key, expected in zip(('d', 'v', 'h', 'w'), (d, v, h, w)):
                compare(item[key], expected, 'matrix/%s/%s/%s/%s' % (n, m, code, key))
            for minimum, actual in zip((1, 2, 4), item['q']):
                compare(actual, expected_summary(rows, d, v, w, minimum), 'summary/%s/%s/%s/%s' % (n, m, code, minimum))
            matrix_cases += 1
        elif item['kind'] == 'distance':
            c, metric = item['case'], item['metric']
            a = [[((c*17+i*7+k*11) % 19-9)/4 for k in range(3)] for i in range(3)]
            b = [[((c*13+i*11+k*3) % 23-11)/4 for k in range(3)] for i in range(4)]
            grid = [[distance(x, y, metric) for y in b] for x in a]
            compare(item['grid'], grid, 'distance')
            compare(item['cross'], [[int(d <= 2.5) for d in row] for row in grid], 'cross')
            square = [[distance(x, y, metric) for y in a] for x in a]
            compare(item['self'], [[-1 if i == j else int(square[i][j] <= 2.5) for j in range(3)] for i in range(3)], 'self')
            observations = sorted(square[i][j] for i in range(3) for j in range(3) if i != j)
            threshold = observations[math.ceil(0.3*len(observations))-1]
            target = [[-1 if i == j else int(square[i][j] <= threshold) for j in range(3)] for i in range(3)]
            compare(item['threshold'], threshold, 'threshold')
            compare(item['target'], target, 'target')
            compare(item['rate'], sum(v == 1 for row in target for v in row)/6, 'achieved')
            metric_cases += 1
        else:
            raise AssertionError('unknown oracle record')
    assert matrix_cases == sum(3**(n*m) for n in range(1, 4) for m in range(1, 4))
    assert metric_cases == 384
    report = dict(target=args.target, matrix_cases=matrix_cases, summaries=matrix_cases*3,
                  metric_cases=metric_cases, mismatches=0,
                  output_sha256=hashlib.sha256(result.stdout).hexdigest())
    if args.report:
        Path(args.report).write_text(json.dumps(report, indent=2)+'\n', encoding='utf-8')
    print(json.dumps(report, sort_keys=True))


if __name__ == '__main__':
    main()
