# shared by apply.sh and init.sh
ref="${DEV_TEMPLATES_REF:-github:bulent-kopuklu/dev-templates}"

# nix flake init exits 1 when any file already exists; the rest is still written.
init() {
  nix flake init -t "${ref}#$1" 2>&1 | while IFS= read -r line; do
    case "$line" in
      wrote:*)     f=${line#wrote: \"}; f=${f%\"}; [ -d "$f" ] || echo "created: ${f#"$PWD"/}" ;;
      refusing*)   f=${line#refusing to overwrite existing file \"}; f=${f%\"}; echo "kept:    ${f#"$PWD"/}" ;;
    esac
  done || true
}
