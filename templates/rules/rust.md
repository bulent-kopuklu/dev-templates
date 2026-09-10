# Rust Kuralları

Bu dosya global geliştirme kurallarını Rust'a özgü olarak somutlaştırır.
Global kuralla çelişmez; onun Rust'taki karşılığını tanımlar.

## Modül Düzeni
- Tek dosyalık modüller için `mod.rs` KULLANMA, düz dosya kullan: `cbus.rs`, `saga.rs`.
- Alt modülü olan modüller için `core.rs` + `core/` ikilisi (klasör adıyla aynı
  isimde dosya, `mod.rs` rolünü üstlenir).
- Yeni modül açarken bu kurala uy; `mod.rs` stiline geri dönme.

## Dayanıklılık (7/24 servis)
Hedef "hiç panic olmasın" değil — panik servisi DÜŞÜRMESİN, yayılmasın, sessizce yutulmasın.
- `unwrap()` / `expect()` / `panic!()` / `unreachable!()` / `todo!()` yerine hatayı
  `Result` ile döndür; çağıran karar versin.
- Array/slice indexleme yerine `.get()`; tamsayı taşmasında `checked_*` / `saturating_*`.
- Beklenen/geçici hatalar (ağ, I/O, parse) panik değildir — `Result` ile ele al,
  logla, gerekiyorsa retry/backoff uygula.
- Geri kazanılamayan invariant ihlali panik edebilir, ama:
  - spawn edilen her task panik'e karşı izole olmalı; `JoinHandle` sonucu kontrol edilmeli.
  - kritik task panic'inde supervisor yeniden başlatmalı, durumu loglamalı + metriğe yazmalı.
- `tokio` task'i sessizce ölmemeli: `JoinHandle` sonucunu yut(ma), logla.
- FFI / `cdylib` sınırında panik UB'dir — `std::panic::catch_unwind` ile sarmala.
- Her hata yolu yapılandırılmış log + metrik üretmeli. Sessiz hata yok.
- `expect()` yalnızca testte ve gerçekten imkânsız durumda, gerekçe yorumuyla kabul.
  ("İmkânsız sandığın için sessiz panic atma" — global "Önce Sadelik" kuralının Rust karşılığı.)

## Async Runtime
- Uygulama katmanında tek async runtime: **tokio**. Başka runtime (async-std vb.) ekleme.
- Yeniden kullanılabilir kütüphane crate'leri mümkünse runtime-agnostic kalsın
  (sadece `Future`/`Stream` döndür, runtime'a bağlanma).
- CPU-bound iş async task'ta çalıştırılmaz: `spawn_blocking` veya ayrı thread pool kullan.
- Bloklayan senkron çağrıyı (sync dosya I/O, sync DB driver) async context'te doğrudan
  çağırma — `spawn_blocking` ile sarmala.

## Fonksiyonel Stil (global "Fonksiyonel Tercih"in Rust karşılığı)
- Global kuraldaki "fonksiyonel tercih" Rust'ta şu demek:
  - Async akışlar: `futures::Stream` + `StreamExt` kombinatörleri
    (`map`, `filter`, `then`, `and_then`, `scan`, `fold`, `buffer_unordered`).
  - Senkron veri: `Iterator` kombinatörleri (`map`/`filter`/`collect`/`fold`/`try_fold`),
    `for`+mutasyon yerine.
  - `Option`/`Result` zincirleri: `map`/`and_then`/`ok_or`/`?`, manuel `match` azalt.
  - Veri + davranış: `enum` + pattern matching; `trait` sadece gerçek polimorfizm gerekince.
- Manuel `loop { recv().await }` yerine Stream pipeline tercih et.
  NATS/event consumer'ları Stream olarak sar; ardışık dönüşümleri pipeline yap.
- Backpressure: `buffer_unordered(n)` veya bounded channel. Unbounded channel kullanma
  (7/24 serviste bellek patlatır).

### Performans sınırı (global "performans pahalıysa imperatif serbest"in somutu)
- Iterator/Stream kombinatörleri kendi başına maliyetsizdir (zero-cost, monomorphize).
- Maliyet kombinatörden değil; fonksiyonel saflık için eklenen `clone()`,
  `Rc<RefCell>` / `Arc<Mutex>` ve `Box<dyn Fn>`'den gelir.
- I/O-bound akışlarda (event consumer, relay, saga) bu maliyet gürültü seviyesinde —
  rahatça fonksiyonel yaz, kopyalamaktan çekinme.
- Hot path / CPU-bound döngüde saflık uğruna allocation ekleme. Sahipliği akıtarak
  (move) çöz; gerekiyorsa imperatif yaz.
- Closure'ları kombinatörlere `impl Fn` (generic) geçir, `dyn` boxed değil.

## Referans Kod (C++/Java → Rust)
- Eski C++/Java kodu yalnızca DAVRANIŞ/NİYET referansıdır, çevrilecek şablon değil.
- "Bu kod ne yapıyor / hangi problemi çözüyor?" diye düşün; satır satır çevirme (transliteration).
- "Rust'ta bu nasıl yapılır?" diye yeniden tasarla; kaynak dilin desenini taşıma.

Taşıma (yapma):
- OOP sınıf hiyerarşisi / inheritance → körü körüne `trait`'e aktarma; çoğu zaman
  `enum` + pattern matching daha idiomatik.
- Java null / C++ pointer → `Option`/`Result` ile düşün; `unwrap` ile null taklidi yapma.
- Paylaşımlı mutable durum → otomatik `Arc<Mutex>` / `Rc<RefCell>`'e çevirme;
  önce sahiplik/move ile çözülebilir mi bak.
- Exception / try-catch → `Result` + `?` ile yeniden kur, panic'e map etme.
- Defansif kopya (Java clone, C++ copy-ctor) → move/borrow varken `clone` ekleme.
- Getter/setter, builder boilerplate → Rust'ta gereksizse ekleme.

İdiomatik tercih:
- Hata: `Result`/`?`; kütüphanede `thiserror`, uygulamada `anyhow`.
- Kaynak yönetimi: RAII / `Drop`, manuel cleanup değil.
- Şüphedeysen C++/Java desenini taşımak yerine idiomatik Rust alternatifini öner,
  nedenini bir cümleyle açıkla. "Java'da şöyleydi" değil, "Rust'ta bu problemi şöyle çözeriz".

## Yorum Disiplini (Rust somutu)
Global "Yorum Disiplini"nin Rust karşılığı; aynı iki yüz.
- **Test, Rust'ta:** imza zaten çok söyler — param tipleri, `-> Result<T, E>` / `Option<T>`,
  `&mut self` (mutasyon), sahiplik, trait bound'ları. Yorum bunların tekrarıysa (`// i'yi artır`;
  `fn sum` üstüne `/// returns the sum`) → sil. İmzanın söyleyemediğini söylüyorsa kalır.
- **Sıradan kod → yorum yok.** Anlaşılmıyorsa rename/extract/tip ile kodu düzelt, yorumla örtme.
  Satır içi `//` açıklayıcı yorum yazma.
- **State machine / protokol akışı → flow-map yorumu var** (örn. `splice_sm.rs`, `schedule.rs`):
  bir state neden var, `tick` sırası/önceliği neden bu, `end_pts: Option<u64>` neden cue-in bekler —
  imzanın ötesi, okuyana harita. Yazmak flow'u + Rust'ı bilmeyi ister; yanlış harita yoktan kötüdür.
- **Planlama kimliği koda girmez** (US/FR/T/phase/ticket); gerekçe = gerçek neden, referans = stabil
  dış standart (`ANSI/SCTE 35-1 §9.x`), numara değil.
- **Doc-comment (`///`, `//!`) yalnızca public yüzeyde:** sözleşme = "ne + nasıl kullanılır" + imzada
  görünmeyen yan etki (`&mut self` neyi değiştirir), dönüşün anlamı, `# Errors` / `# Panics` /
  precondition. Asla "nasıl çalışır" (implementasyon). Private item'a doc yazma.
- **Değişiklikte varsayılan SİL:** fonksiyon değişince kapsamdaki doc/yorum çürür — birebir doğru
  değilse sil (şüphedeysen sil). Stale doc = bug; davranışı yorumdan değil gövdeden oku.

## Tasarım Önce (Rust somutu)
Global "Tasarım Önce, Kod Sonra" akışında, kod gövdesi yerine iskelet sun:
- `trait` tanımları: sadece imzalar (`fn ...;`), gövde yok.
- `struct`/`enum`: alanlar + tipler.
- Fonksiyon imzaları: parametre + dönüş tipi (`-> Result<T, E>`), gövde `todo!()`.
- Her yeni tip/trait için tek cümlelik sorumluluk + call-site kullanım örneği.
- Onay alınmadan gövde doldurma. Onay sonrası iskelette olmayan yeni public tip
  çıkarsa tekrar onaya dön.

## Lint (kuralları zorla)
Crate köküne (`lib.rs` / `main.rs`):
```rust
#![warn(clippy::unwrap_used)]
#![warn(clippy::expect_used)]
#![warn(clippy::panic)]
```
- Commit öncesi: `cargo fmt && cargo clippy --all-targets -- -D warnings && cargo test`.
- `#[cfg(test)]` modüllerinde yukarıdaki lint'ler gevşetilebilir.
