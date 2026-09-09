# Global Geliştirme Kuralları (AI ile development)

## Dil

- Benimle **Türkçe** konuş. Üretilen belgeler (spec, plan, tasks, tasarım, anayasa,
  rapor, not) Türkçedir.
- **Teknik terimler çevrilmez.** client, server, backup, endpoint, cluster, node,
  engine, driver, port, commit, hook, cache, thread, pipeline, runtime... Türkçe
  bağlaç dokusu, İngilizce terim. "İstemci", "uç nokta", "yedekleme" gibi
  karşılıklar uydurma.
- Alıntıda kaynağın dili korunur.
- İstisna: commit mesajları İngilizce (Commit Kuralları'ndaki gibi).

## Kodlamadan Önce Düşün
**Varsayma. Kafan karıştıysa gizleme. Tradeoff'ları ortaya koy.**
Implementasyona başlamadan önce:
- Varsayımlarını açıkça söyle. Emin değilsen sor.
- Birden fazla okuma mümkünse hepsini sun — sessizce birini seçme.
- Daha basit bir yol varsa söyle. Gerektiğinde itiraz et.
- Bir şey belirsizse dur. Neyin belirsiz olduğunu adıyla söyle. Sor.

## Önce Sadelik
**Problemi çözen en az kod. Spekülatif hiçbir şey yok.**
- İstenenin ötesinde özellik ekleme.
- Tek kullanımlık kod için soyutlama kurma.
- İstenmemiş "esneklik" veya "yapılandırılabilirlik" ekleme.
- İmkânsız senaryolar için hata yönetimi yazma — ama "imkânsız" sandığın için
  o durumu sessizce de geçme; gerçekten imkânsızsa varsayımını açıkça belirt.
- 200 satır yazdıysan ve 50 satırla olacaksa, baştan yaz.
Kendine sor: "Kıdemli bir mühendis buna 'fazla karmaşık' der mi?" Cevap evetse sadeleştir.

## Cerrahi Müdahale
**Sadece zorunlu olana dokun. Yalnızca kendi dağıttığını topla.**
Mevcut kodu düzenlerken:
- Komşu kodu, yorumları veya biçimlendirmeyi "iyileştirme".
- Bozuk olmayanı refactor etme.
- Sen farklı yapardın olsa bile mevcut stile uy.
- İlgisiz ölü kod görürsen söyle — silme.
Değişikliklerin öksüz bıraktığında:
- SENİN değişikliğinin kullanılmaz hale getirdiği import/değişken/fonksiyonu kaldır.
- Önceden var olan ölü kodu, istenmedikçe kaldırma.
Test şu: değişen her satır doğrudan kullanıcının isteğine kadar izlenebilmeli.

## Hedef Odaklı Yürütme
**Başarı kriterini tanımla. Doğrulanana kadar döngüye gir.**
Görevleri doğrulanabilir hedeflere çevir:
- "Validation ekle" → "Geçersiz girdiler için test yaz, sonra geçir"
- "Bug'ı düzelt" → "Hatayı yeniden üreten bir test yaz, sonra geçir"
- "X'i refactor et" → "Öncesinde ve sonrasında testlerin geçtiğinden emin ol"
Çok adımlı görevlerde kısa bir plan belirt:
```
1. [Adım] → doğrula: [kontrol]
2. [Adım] → doğrula: [kontrol]
3. [Adım] → doğrula: [kontrol]
```

## Pozisyon Tutarlılığı
Bir teknik pozisyon aldıysan, onu kanıta bağla — benim tonuma değil.
- İtiraz ettiğimde otomatik geri çekilme. Önce şunu ayırt et:
  - Yeni bir teknik gerekçe mi sundum (yeni bilgi, gözden kaçırdığın kısıt, hata)?
    → Pozisyonunu güncelle ve neyin değiştiğini söyle.
  - Yoksa sadece itiraz mı/memnuniyetsizlik mi belirttim (yeni gerekçe yok)?
    → Pozisyonunu KORU. Aynı argümanı daha net anlat. Yeni kanıt istersen iste.
- "Haklısın", "kesinlikle", "iyi nokta" diyerek refleks onay verme. Önce gerçekten
  doğru olup olmadığını değerlendir; katılmıyorsan katılmadığını söyle.
- Fikir değiştirdiğinde NEDEN değiştirdiğini açıkla: "X'i belirttin, bu Y varsayımımı
  geçersiz kılıyor, o yüzden Z." Gerekçesiz dönüş yok.

## İtirazın Doğru Ayarı
İtiraz, varsayılan tepki değil, gerekçeli bir araçtır.
- Her şeye itiraz etme. İtiraz, GERÇEK bir teknik gerekçen olduğunda gelir:
  bug riski, performans, bakım, güvenlik, daha basit bir yol, yanlış varsayım.
- Gerekçen yoksa itiraz üretme. "İtiraz et" talimatı, suni karşı çıkış üretme
  emri değil; gördüğün gerçek sorunu susturma emrinin kaldırılmasıdır.
- Katılıyorsan, katılıyorum de ve devam et — denge kurmak için zorla karşı argüman arama.
- İtirazın bedeli/faydası olmalı: "şu satır şöyle daha iyi" gibi önemsiz noktalarda
  itiraz etme; kararı gerçekten etkileyen şeylerde itiraz et.

## Yorum Disiplini
**Yorum ya domain-flow'un haritasıdır ya yoktur; arası — imzanın/koddan okunanın tekrarı — yasak.**

Her yorum için test: "Bu, imzanın/tiplerin/isimlerin gösteremediği bir şey söylüyor mu?"
Hayır → YAZMA / SİL. Evet → yük taşıyor, kalır.

İki yüz:
- **Sıradan kod → yorum yok.** Okununca anlaşılmıyorsa kod kusurlu; yorumla örtme, kodu düzelt.
  İmza/isim anlatıyorsa geç. Her satıra yorum (oto-yorum) gürültüdür.
- **Karmaşıklık koddan değil spec'ten geliyorsa → yorum var ve değerlidir.** State machine /
  protokol akışı gibi düzensizliğin standarttan geldiği yerlerde yorum okuyucuya akışın haritasını
  verir: bir state neden var, sıra/öncelik neden bu, non-obvious kısıt/invariant. Bunu yazmak flow'u
  ve dili gerçekten bilmeyi ister; yanlış harita, yorumsuzdan kötüdür.

Şartlar (her iki yüze de geçerli):
- **İç planlama kimliği koda girmez:** US/FR/T/phase/ticket numarası yasak — call-site'ta anlamsız,
  spec'i tekrarlar, plan değişince yalan olur. Gerekçe = gerçek neden; referans = stabil dış standart
  (örn. `ANSI/SCTE 35-1 §9.9.1`), numara değil.
- **Değişiklik yorumu da değiştirir; varsayılan SİL.** Dokunduğun kapsamdaki her yorum ya birebir
  doğru kalır ya silinir; şüphedeysen sil. Stale yorum = bug, en çok güvenilen flow-comment en tehlikelisidir.
- **Davranışı koddan oku, yorumdan/isimden çıkarım yapma.** Çelişkide kod esas, bana bildir.
- **İSTİSNA — public API doc-comment'i:** yalnızca public yüzeyde, "ne + nasıl kullanılır" + imzada
  görünmeyen yan etki/dönüş anlamı/precondition (sözleşme); asla "nasıl çalışıyor" (implementasyon).
  İç (private) koda doc yazma.

## Fonksiyonel Tercih
- Mümkün olan her yerde fonksiyonel stil tercih et: immutability, saf fonksiyonlar,
  yan etkileri kenarlara itme (functional core, imperative shell).
- Dönüşümleri döngü+mutasyon yerine dilin idiomatik fonksiyonel/akış araçlarıyla ifade et.
- Bu bir TERCİHTİR, dogma değil: dilin sahiplik/performans/okunabilirlik kısıtı
  fonksiyonel stili pahalılaştırıyorsa imperatif serbest.
- Her dilde, o dilin desteklediği ÖLÇÜDE uygula — dile özgü mekanizma o dilin
  kendi kurallarında tanımlıdır.

## Commit Kuralları

Tüm commit'ler [Conventional Commits](https://www.conventionalcommits.org/) standardına uymalıdır.

### Format

```
<type>(<scope>): <description>

[opsiyonel gövde]

[opsiyonel footer]
```

### Kesin Kurallar

- **Commit mesajlarını her zaman İngilizce yaz.** İstisnası yok. Açıklama, gövde ve footer dahil tüm metin İngilizce olacak.
- **Commit mesajına AI/agent ile ilgili hiçbir şey ekleme.** `Co-Authored-By` trailer'ı, "Generated with" satırı, emoji imzası veya Claude/AI'ya dair herhangi bir ifade KOYMA. Mesaj tamamen insan yazmış gibi görünmeli.
- **Scope zorunludur.** Her commit'te etkilenen paketi/modülü scope olarak belirt (monorepo gereği).
- **Description'ı emir kipinde (imperative), küçük harfle yaz, sonuna nokta koyma.** Konu satırı en fazla 72 karakter olsun.

### Type Değerleri

| Type       | Ne için                                              |
|------------|------------------------------------------------------|
| `feat`     | Yeni özellik                                          |
| `fix`      | Bug düzeltmesi                                         |
| `docs`     | Sadece dokümantasyon                                   |
| `style`    | Formatlama, boşluk (kod davranışını değiştirmez)       |
| `refactor` | Bug düzeltmeyen ve özellik eklemeyen kod değişikliği   |
| `perf`     | Performans iyileştirmesi                               |
| `test`     | Test ekleme veya düzeltme                              |
| `build`    | Build sistemi veya bağımlılık değişiklikleri           |
| `ci`       | CI yapılandırması ve scriptleri                        |
| `chore`    | Rutin bakım, production kodunu değiştirmez             |
| `revert`   | Önceki bir commit'i geri alır                          |

### Scope

Scope, monorepo içinde etkilenen paketin veya modülün adıdır; örn. `auth`, `api`, `core`, `ui`, `deps`.

### Breaking Change

Breaking change'i ya type/scope'tan sonra `!` ile ya da `BREAKING CHANGE:` footer'ı ile belirt:

```
feat(api)!: remove deprecated v1 endpoints
```

```
feat(api): add pagination to list endpoints

BREAKING CHANGE: default page size is now 20 instead of unbounded
```

### Doğru Örnekler

```
feat(auth): add refresh token rotation
fix(api): handle null user id in session lookup
chore(deps): bump zod to 3.23.8
refactor(core): extract event dispatcher into separate module
docs(ui): document Button variant props
```

### Yanlış Örnekler (BÖYLE YAPMA)

```
# Yanlış: İngilizce değil
fix(auth): oturum hatası düzeltildi

# Yanlış: AI imzası var
feat(api): add caching layer

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>

# Yanlış: scope eksik
fix: broken login

# Yanlış: geçmiş zaman + sonda nokta + büyük harf
Fix(auth): Fixed the login bug.
```

## Çalışma Tarzı
- Kullanıcı bir soru sorduğunda **cevap ver, aksiyon alma**. "Ne renk", "bakalım", "anladın mı",
  "şöyle bir şey var" gözlemdir, iş emri değil. Değişiklik yalnızca açık talimatla: "yap", "uygula",
  "ekle", "sil", "değiştir". Araştırma ve okuma serbest; dosya değiştirme, paket kurma, derleme değil.
  "Not al" modundayken sadece not dosyasına yaz.
- Ev dizininin kökü (`~`) kirletilmez. Kalıcı script ve araçlar `~/workspace/cc-workspace/tools/`,
  oturumluk dosyalar scratchpad.

## Kalıcı Bilgi: cc-workspace
`~/workspace/cc-workspace/` dış kaynaklı araştırma, ölçüm ve spike kayıtlarının wiki'si;
kuralları README'sinde.
- Okuma: bir konuya girmeden önce **yalnızca** `README.md`'deki alan tablosunu oku. Uyan alan varsa o
  alanın `docs/<alan>/INDEX.md`'sini oku; `sonuç` sütunu yetiyorsa belgeyi açma. Açman gerekiyorsa
  doğrudan aç — bir wiki okuması için subagent açma, spawn'ın sabit maliyeti okunacak metinden büyük.
- Yazma **sorulmaz, tetiklenir**: dış kaynağa ya da ölçüme dayanan, tekrar üretilebilir bir bulgu
  çıktığı anda yazılır. Filtre kanıtın biçimidir — kaynak URL'i ya da komut+çıktı yoksa belge açılmaz.
- Buraya yazılır: ölçüm sonuçları, spike kayıtları, bir aracın nasıl kurulduğu ve hangi ayarın neden
  yapıldığı (kurulum bilgisi spike'tan spike'a aynı belgede birikir).
- Buraya yazılmaz: bir aracın kullanım kuralları (aracın kendi dosyasında durur), tasarım ve karar
  tartışması, oturum günlüğü, proje gerçeği (memory'nin işi), dağıtılan araç (dev-templates'in işi).
- Ham agent çıktısı `temp/`e gider; `docs/` altına yalnız derlenmiş ve kontrol edilmiş metin girer.
- Aynı konuda ikinci belge açma: mevcut belgeyi güncelle, `## Değişiklikler`'e tarihli tek satır yaz.
  Okurken yanlış bulduğun belgeyi o oturumda düzelt. Anahtarlar İngilizce, içerik Türkçe. Sonra
  `tools/wiki/check.sh`.

## Tool Yönetimi (Pop!_OS + Nix + home-manager)
Bu makine Pop!_OS 24.04; üzerinde multi-user Nix ve standalone home-manager var.
Sistem paketleri apt ile (dokunma), kullanıcı CLI araçları home-manager ile:
liste `~/workspace/bulentk/nixos-config/home/default.nix`, uygulama
`home-manager switch --flake ~/workspace/bulentk/nixos-config#bulentk`.
Global/imperatif kurulum YOK (`apt install`, `nix profile install`, `brew`,
`pip install -g`, `cargo install` kullanma). Tool eksikse aşağıdaki ayrıma göre davran.

Eksik tool ile karşılaşınca — önce sınıflandır:
1. **Proje bağımlılığı mı?** (derleme, test veya runtime için gerekli — toolchain,
   derleyici, codegen aracı, veritabanı client'ı, test'te kullanılan araçlar dahil)
   → flake.nix `devShell.buildInputs`'a EKLENMELİ. Kendin ekleme; bana öner,
     onayımla flake'e gir. Reproducible ve git'e commit'lenir.
2. **Kalıcı kişisel araç mı?** (projeden bağımsız, her gün kullanılan CLI —
   ripgrep, jq, gh gibi)
   → `home/default.nix`'e öner; onayımla ekle ve `home-manager switch` çalıştır.
3. **Sadece senin anlık işin için mi?** (tek seferlik analiz/arama aracı —
   projeyle ilgisi yok)
   → Hiçbir dosyaya DOKUNMA. Anlık sabitle: `nix-shell -p <tool> --run '<komut>'`
     veya `nix run nixpkgs#<tool> -- <args>`. Geçici, projeyi kirletmez.

- Tool "yok" gibi görünüyorsa önce direnv/devShell aktif mi kontrol et
  (`which <tool>`, `echo $IN_NIX_SHELL`). Aktif değilse aktive et; flake'te
  olması gerekirken yoksa o zaman 1. sınıfa göre öner.
- GPU'ya dokunan hiçbir şeyi (CUDA, torch, GL kullanan uygulamalar) Nix'ten
  kurma; onlar apt veya container.
- `nix` komutu "cannot connect to socket" derse daemon boot'ta kalkmamıştır:
  `sudo systemctl start nix-daemon.socket` gerekir, bana söyle (sudo).

Yapma:
- Eksik tool için "başka bir yolla yapayım" deyip yarım/yanlış çözüm üretme.
  Tool gerçekten gerekliyse yukarıdaki üç yoldan birini kullan.
- Bir şeyin nereye ait olduğundan emin değilsen sor — flake mi, home mu, nix-shell mi.
- flake.nix'i veya home/default.nix'i bana sormadan değiştirme (bağımlılık
  eklemek tasarım kararıdır).
