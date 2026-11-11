"""Execute the three public workflows and inspect their actual structured artifacts."""
import argparse, csv, io, json, os, subprocess, xml.etree.ElementTree as ET
from pathlib import Path


def verify(root, target):
    reports = {}
    for name in ('signal', 'regime', 'coupling'):
        cmd = [os.environ.get('MOON', 'moon'), 'run', 'examples/'+name, '--target', target]
        result = subprocess.run(cmd, cwd=root, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        if result.returncode:
            raise RuntimeError(result.stderr.decode('utf-8', 'replace'))
        item = json.loads(result.stdout)
        assert item['workflow'] == name
        reports[name] = item
    signal = reports['signal']
    assert signal['report']['samples'] == 7
    assert signal['report']['summary']['recurrent'] == 18
    assert signal['report']['summary']['eligible'] == 42
    assert abs(signal['report']['summary']['recurrence_rate']-3/7) < 1e-12
    svg = ET.fromstring(signal['svg'])
    assert svg.tag == '{http://www.w3.org/2000/svg}svg'
    assert svg.attrib['width'] == '56'
    assert len(list(svg.iter('{http://www.w3.org/2000/svg}rect'))) == 26
    windows = list(csv.DictReader(io.StringIO(reports['regime']['windows_csv'])))
    assert len(windows) == 2
    assert [float(w['recurrence_rate']) for w in windows] == [1.0, 0.0]
    assert [(int(w['start']), int(w['stop'])) for w in windows] == [(0, 4), (4, 8)]
    scan = list(csv.DictReader(io.StringIO(reports['regime']['thresholds_csv'])))
    assert [int(s['recurrent']) for s in scan] == [12, 26, 56]
    coupling = reports['coupling']
    assert coupling['best_lag'] == 1
    assert coupling['jaccard'] == 1.0
    assert coupling['common_eligible'] == 30
    assert coupling['joint']['recurrent'] == 6
    assert len(list(csv.DictReader(io.StringIO(coupling['profile_csv'])))) == 5
    return dict(target=target, workflows=['signal', 'regime', 'coupling'], passed=3)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--target', default='wasm-gc')
    parser.add_argument('--root', type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument('--report', type=Path)
    args = parser.parse_args()
    result = verify(args.root, args.target)
    if args.report:
        args.report.write_text(json.dumps(result, indent=2)+'\n', encoding='utf-8')
    print(json.dumps(result))
