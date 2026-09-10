# Her bileşen components/<ad>/ altında, tek dilde, kendi manifest'iyle durur.
# Bu dosya bileşenleri listelemez: dili manifest'ten okur. Yeni bileşen için
# dizini açmak yeter.
#
#   make                                   build, debug, host
#   make build VARIANT=release TARGET=aarch64
#   make test COMPONENTS="api agent"
#   make build-agent                       tek bileşen
#   make dist TARGET=armv7                 release çıktısı → dist/armv7/
#   make clean | distclean

VARIANT    ?= debug
TARGET     ?= host
COMPONENTS ?= $(notdir $(wildcard components/*))
BUILD_DIR  ?= build
DIST_DIR   ?= dist

VARIANTS := debug release
TARGETS  := host aarch64 armv7
$(if $(filter $(VARIANT),$(VARIANTS)),,$(error VARIANT=$(VARIANT); seçenekler: $(VARIANTS)))
$(if $(filter $(TARGET),$(TARGETS)),,$(error TARGET=$(TARGET); seçenekler: $(TARGETS)))

BUILD := $(abspath $(BUILD_DIR))
OUT   := $(BUILD)/$(TARGET)/$(VARIANT)
BIN   := $(OUT)/bin
CROSS := $(filter-out host,$(TARGET))

# Aynı hedefin üç toolchain'deki adı farklı. C prefix'i devshell'in nix cross
# derleyicisinden gelir (armv7l), Rust triple'ı rustup'tan (armv7).
goarch_aarch64 := GOARCH=arm64
goarch_armv7   := GOARCH=arm GOARM=7
triple_aarch64 := aarch64-unknown-linux-gnu
triple_armv7   := armv7-unknown-linux-gnueabihf
ccpfx_aarch64  := aarch64-unknown-linux-gnu-
ccpfx_armv7    := armv7l-unknown-linux-gnueabihf-

manifest_go.mod         := go
manifest_Cargo.toml     := rust
manifest_CMakeLists.txt := cpp
manifest_package.json   := node
manifests = $(notdir $(wildcard $(addprefix components/$1/,go.mod Cargo.toml CMakeLists.txt package.json)))
kind = $(if $(filter 1,$(words $(call manifests,$1))),$(manifest_$(call manifests,$1)),$(error components/$1: tek manifest bekleniyor, bulunan: $(or $(call manifests,$1),yok)))

go_flags_debug   := -gcflags='all=-N -l'
go_flags_release := -trimpath -ldflags='-s -w'
go_build = cd components/$1 && $(if $(CROSS),GOOS=linux $(goarch_$(TARGET))) go build $(go_flags_$(VARIANT)) -o $(BIN)/ ./...
go_test  = cd components/$1 && go test ./...
go_lint  = cd components/$1 && golangci-lint run ./...

# Cargo'nun kendi dizin düzeni var (<triple>/<profil>); target dizini bütün
# hedeflere ortak, bağımlılıklar bir kez derlenir. Çalıştırılabilirler bin/'e
# kopyalanır ki dist her dil için aynı yerden toplasın.
cargo       = cargo $2 --manifest-path components/$1/Cargo.toml --target-dir $(BUILD)/cargo
rust_profile = $(BUILD)/cargo/$(if $(CROSS),$(triple_$(TARGET))/)$(VARIANT)
rust_build  = $(call cargo,$1,build) $(if $(CROSS),--target $(triple_$(TARGET))) $(if $(filter release,$(VARIANT)),--release) \
              && find $(rust_profile) -maxdepth 1 -type f -executable ! -name '*.*' -exec cp -t $(BIN) {} +
rust_test   = $(call cargo,$1,test) $(if $(filter release,$(VARIANT)),--release)
rust_lint   = $(call cargo,$1,clippy) --all-targets -- -D warnings

cmake_type_debug   := Debug
cmake_type_release := Release
cpp_dir   = $(OUT)/cmake/$1
cpp_cross = $(if $(CROSS),-DCMAKE_SYSTEM_NAME=Linux -DCMAKE_SYSTEM_PROCESSOR=$(TARGET) \
              -DCMAKE_C_COMPILER=$(ccpfx_$(TARGET))clang -DCMAKE_CXX_COMPILER=$(ccpfx_$(TARGET))clang++)
cpp_build = cmake -S components/$1 -B $(cpp_dir) -G Ninja -DCMAKE_BUILD_TYPE=$(cmake_type_$(VARIANT)) \
              -DCMAKE_INSTALL_PREFIX=$(OUT) $(cpp_cross) \
            && cmake --build $(cpp_dir) && cmake --install $(cpp_dir)
cpp_test  = $(call cpp_build,$1) && ctest --test-dir $(cpp_dir) --output-on-failure
cpp_lint  = $(call cpp_build,$1) && run-clang-tidy -quiet -p $(cpp_dir) $(abspath components/$1)

node_deps  = cd components/$1 && { [ -d node_modules ] || npm install --no-audit --no-fund; }
node_build = $(node_deps) && npm run --if-present build
node_test  = $(node_deps) && npm run --if-present test
node_lint  = biome check components/$1

.DEFAULT_GOAL := build
.PHONY: build test lint dist clean distclean

build: $(addprefix build-,$(COMPONENTS))
test:  $(addprefix test-,$(COMPONENTS))
lint:  $(addprefix lint-,$(COMPONENTS))

build-%: | $(BIN)
	$(call $(call kind,$*)_build,$*)

test-%:
	$(if $(CROSS),$(error test yalnız host'ta koşar; TARGET=$(TARGET) için make build))
	$(call $(call kind,$*)_test,$*)

lint-%:
	$(call $(call kind,$*)_lint,$*)

$(BIN):
	mkdir -p $@

dist:
	$(MAKE) build VARIANT=release
	mkdir -p $(DIST_DIR)/$(TARGET)
	cp -a $(BUILD)/$(TARGET)/release/bin/. $(DIST_DIR)/$(TARGET)/

clean:
	rm -rf $(BUILD_DIR)

distclean: clean
	rm -rf $(DIST_DIR) components/*/node_modules components/*/target
