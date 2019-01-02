import subprocess, json

def get_derivation_out_path(attrname):
    result = subprocess.run(
        [
            'nix', 'eval', 
            'nixpkgs.%s.outPath' % attrname
        ],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE)
    if result.returncode == 0:
        return json.loads(result.stdout)
    else:
        return None

