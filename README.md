# SVT-AV1 nightly and weekend tests

This branch only holds the CI that tests [AOMediaCodec/SVT-AV1](https://github.com/AOMediaCodec/SVT-AV1) on the
supermicro self-hosted runners (supermicro1, 2, 3, 5 and the Mac jimmy; supermicro4 is not used). `main` is a plain copy of the SVT-AV1 code.

- `.github/workflows/nightly-weekend.yml`: the nightly tests (Actions -> SVT-AV1 nightly tests -> Run workflow;
  SVT-AV1 ref or PR number).
- `.github/workflows/weekend.yml`: the weekend tests, in 16 lanes of tests run one after another
  (Actions -> SVT-AV1 weekend tests -> Run workflow).
- `.github/workflows/quick-check.yml`: Cleanup, builds and a few short tests on one machine (+ jimmy).
- `.github/nightly-weekend/setup_github_runners.sh`: installs the 4 runners of one machine
  (`sudo bash setup_github_runners.sh Ubuntu10`; Ubuntu11/12/13/14 on supermicro2/3/4/5).
- `.github/nightly-weekend/setup_github_runner_mac.sh`: installs the Mac runner on jimmy (`sudo bash setup_github_runner_mac.sh`).
