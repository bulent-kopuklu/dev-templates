# PROJECT_NAME

<!-- Tek paragraf: bu proje ne yapar, kim için. -->

## Ortam

- Devshell `flake.nix` ile gelir; `direnv allow` yeter. Toolchain, LSP ve formatter'lar oradan gelir, sistemden değil.
- Diller: LANGS
- Build / test / lint komutları:
  <!-- `cargo build`, `cmake --build build`, `go test ./...` ... -->

## Yerleşim

<!-- Dizinler ve rolleri. -->

## Kurallar

- `~/.claude/CLAUDE.md` içindeki global kurallar burada da geçerli; bu dosya yalnızca projeye özel olanları taşır.
- Formatlama `PostToolUse` hook'u ile otomatik (`scripts/fmt.sh`). Elle formatlama komutu çalıştırma.

<!-- /init çıktısını bu satırın altına ekle; yukarıdaki bölümleri koru. -->
