# PROJECT_NAME

<!-- Tek paragraf: bu proje ne yapar, kim için. -->

## Ortam

- Devshell `flake.nix` ile gelir; `direnv allow` yeter. Toolchain, LSP ve formatter'lar oradan gelir, sistemden değil.
- Diller: LANGS
- Build / test / lint kökteki `Makefile`'dan: `make`, `make test`, `make lint`,
  `make dist`, `make clean`, `make distclean`. Parametreler (`VARIANT`, `TARGET`,
  `COMPONENTS`) ve varsayılanları dosyanın başında.

## Yerleşim

- Kod yalnız `components/<ad>/` altında durur. Her bileşen tek dildir; manifest'i
  (`go.mod`, `Cargo.toml`, `CMakeLists.txt`, `package.json`) kendi dizinindedir.
  İkinci bir dil gerekiyorsa ikinci bir bileşen açılır.
- Yeni bileşen = `components/` altında yeni dizin. `Makefile`'a dokunulmaz;
  bileşenin dilini manifest'inden okur.
- Kökte yalnız projenin geneline ait olan durur: `Makefile`, `flake.nix`,
  formatter/linter config'leri, `CLAUDE.md`, `README.md`. Spec Kit kullanılıyorsa
  onun yerleri de: `specs/`, `.specify/`, living specs'in `living-specs.yml`'ı ve
  `capabilities/`'i. Kök dizine kaynak kodu ya da bunların dışında yeni dizin
  eklenmez.
- Bileşenler arası sözleşme (proto, OpenAPI) kendi bileşeninde durur
  (`components/<ad>/`, manifest `buf.yaml`). Kodunu onu kullanan her bileşen
  kendi build'inde üretir: Go `//go:generate`, Rust `build.rs`.
- Build çıktısı `build/<target>/<variant>/`, release çıktısı `dist/<target>/`.

<!-- Bileşenler ve rolleri. -->

## Kurallar

- `~/.claude/CLAUDE.md` içindeki global kurallar burada da geçerli; bu dosya yalnızca projeye özel olanları taşır.

<!-- SPECKIT START -->
<!-- SPECKIT END -->

<!-- /init çıktısını bu satırın altına ekle; yukarıdaki bölümleri koru. -->
