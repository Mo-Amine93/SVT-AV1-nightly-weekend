# SVT-AV1 nightly and weekend tests

This branch only holds the CI that tests [AOMediaCodec/SVT-AV1](https://github.com/AOMediaCodec/SVT-AV1) on the
supermicro self-hosted runners. `main` is a plain copy of the SVT-AV1 code.

- `.github/workflows/nightly-weekend.yml`: the tests. Start them from Actions -> SVT-AV1 nightly and weekend tests ->
  Run workflow (mode nightly or weekend, SVT-AV1 ref or PR number).
- `.github/nightly-weekend/setup_github_runners.sh`: installs the 4 runners of one machine
  (`sudo bash setup_github_runners.sh Ubuntu10`; Ubuntu11/12/13/14 on supermicro2/3/4/5).
