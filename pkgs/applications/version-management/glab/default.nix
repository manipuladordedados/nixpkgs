{ lib, buildGoModule, fetchFromGitLab, installShellFiles, stdenv }:

buildGoModule rec {
  pname = "glab";
  version = "1.45.0";

  src = fetchFromGitLab {
    owner = "gitlab-org";
    repo = "cli";
    rev = "v${version}";
    hash = "sha256-jTpddpS+FYSQg2aRxQiVlG+bitiIqmZ4kxOJLPZkICo=";
  };

  vendorHash = "sha256-o0sYObTeDgG+3X3YEnDbk1h4DkEiMwEgYMF7hGjCL3Q=";

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  preCheck = ''
    # failed to read configuration:  mkdir /homeless-shelter: permission denied
    export HOME=$TMPDIR
  '';

  subPackages = [ "cmd/glab" ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall = lib.optionalString (stdenv.hostPlatform == stdenv.buildPlatform) ''
    make manpage
    installManPage share/man/man1/*
    installShellCompletion --cmd glab \
      --bash <($out/bin/glab completion -s bash) \
      --fish <($out/bin/glab completion -s fish) \
      --zsh <($out/bin/glab completion -s zsh)
  '';

  meta = with lib; {
    description = "GitLab CLI tool bringing GitLab to your command line";
    license = licenses.mit;
    homepage = "https://gitlab.com/gitlab-org/cli";
    changelog = "https://gitlab.com/gitlab-org/cli/-/releases/v${version}";
    maintainers = with maintainers; [ freezeboy ];
    mainProgram = "glab";
  };
}
