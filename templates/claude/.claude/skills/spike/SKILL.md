---
name: spike
description: Dış dünyanın davranışını ölçerek öğren ve kaydını bırak. Bir karar "şu araç/servis/kütüphane şöyle davranıyor" cümlesine dayanıyor ve arkasında koşulmuş bir ölçüm yoksa bu skill'i yükle. Tetikleyen durumlar - bir API'nin kısıtı, bir aracın sürüme bağlı davranışı, bir yapılandırmanın gerçekten işe yarayıp yaramadığı, bir performans ya da izolasyon iddiası, "acaba destekliyor mu" diye başlayan her soru. Girdi ne olursa olsun (spec, ticket, tek cümlelik soru) çalışır.
---

# Spike

Bilmediğin bir dış davranışı **ölçerek** öğrenirsin ve kaydını bırakırsın. Kayıt
olmadan yapılan spike, bir sonraki soruda yeniden yapılır ve o zaman da
doğrulanmamış bir cevap üretir.

## Ne zaman spike açılır

Bir iddia kurman gerekiyor ve iddia dış dünyanın davranışı hakkında. Şu üçü
spike'ın yerini **tutmaz**:

- **Bildiğini sanman.** Eğitim verisi hangi sürümün davranışı olduğunu söylemez;
  araç o sürümden beri değişmiş olabilir.
- **Resmî dokümanın öyle yazması.** Belgelenen davranış ile gözlenen davranış
  ayrışır; kararı yalnız gözlenen taşır. Doküman bir başlangıç noktasıdır, kanıt
  değil.
- **Kararın daha önce böyle verilmiş olması.** Kanıt değil alışkanlıktır.

## Ne zaman açılmaz

- Cevap kendi kodumuzun içindeyse — orası testin işi.
- Tek makul yol varsa — orada karar yoktur.
- Soru bir tercihse (iki yol da çalışıyor, hangisini isteriz) — kanıt tercih
  yapmaz, o soru insana gider.

## Sözleşme

Seni çağıran taraf tek şey bekler: **bir kanıt kaydının yolu.** Kayıt varsa
ölçme, yolu hemen döndür. Yoksa spike'ı koş, kaydı tamamla, sonra yolu döndür.
Ölçüm yapılamadıysa yol yerine `ÖLÇÜLEMEDİ` ve neyin eksik olduğu döner — çağıran
taraf kararını ona göre açık bırakır.

## Önce var olana bak

Spike açmadan önce `INDEX.md`'yi oku. Üç sonuçtan biri çıkar:

1. **İşe yarayan, güncel bir kayıt var** — ölçme, ona bağlan. İş bitti.
2. **Kayıt var ama bayat** — ölçülen sürüm artık kullandığın sürüm değil, ya da
   ortam değişmiş. `setup.sh` ve `measure.sh` elinde hazır: sürümü güncelle,
   yeniden koş, **aynı kartı güncelle**. Yeni kart açma — bir soru bir kart
   tutar, geçmişi kartın kendi içinde birikir.
3. **Kayıt yok** — spike açılır. Ama sıfırdan başlama: `INDEX.md`'nin *kurulan
   teknolojiler* sütununa bak, ihtiyacın olan ortamı daha önce kuran bir spike
   varsa onun `setup.sh`'ini **kopyala ve düzenle**. Ortamı keşfetmenin bedeli
   bir kez ödenir.

## Nasıl koşulur

1. **Soruyu tek cümleye indir.** Geçti/kaldı diye cevaplanabilir olmalı.
   "Octavia iyi mi" soru değildir; "aynı load balancer'da aynı protokol ve port
   için ikinci listener kabul ediliyor mu" sorudur.
2. **Sürümü sabitle.** Neyin hangi sürümünü ölçtüğünü bil; sürümsüz bir bulgu
   bir sonraki sürümde sessizce yalan olur.
3. **Düzeneği kur ve koşulabilir bırak.** Tarif edilen düzenek kurulmaz — kuran
   ve sökeni bir script olarak yaz. Ölçümün kendisi de o script'in içinde olsun;
   tırnak içine gömülmüş tek satırlık bir komut ne okunabilir ne düzeltilebilir.
4. **Kontrolünü koy.** Ölçümün bir şey ölçtüğünü göster: pozitif kontrol ölçüm
   noktasının canlı olduğunu, negatif kontrol iddianın yanlışlanabildiğini
   gösterir. **Kontrolü olmayan spike sonuç üretmez** — hiçbir şey ölçmeyen bir
   sayaç da sıfır gösterir.
5. **Koş ve ham çıktıyı sakla.** Çıktı üretilmediyse sonuç sıfır değil hatadır.

## Ölçümün kendi tuzakları

Ölçüm arızalarının neredeyse tamamı **ölçülen şeyin sonucu gibi görünür**:

- **Yanlış yönde güvenli** — düzenek çalışmadı, sonuç "iddia doğrulandı" gibi
  okundu. En sık olanı budur ve sessizce kabul edilir.
- **Ters yönde** — ölçüm aracı bozuktu, olmayan bir sorun var göründü.
- **Doğru sayı, yanlış sorunun cevabı** — en tehlikelisi; kayıtta hakiki bir
  ölçüm gibi durur.

Buna karşı tek kural: **ölçebildiğini göstermeden ölçtüğünü iddia etme.** Buna
başlangıç durumu da dahildir — bozuk bir düzenekte başlayan koşu, ölçtüğünü
değil düzeneğini raporlar. Bir önceki koşudan kalan artık da düzeneğin
parçasıdır: her koşu temiz başladığını göstermeli.

## Büyük çıktıyı yerel modele ele

Kurulum ve ölçüm log'ları büyüktür, gürültülüdür ve çoğu satırı işe yaramaz.
Hata satırını bulmak, tekrarlayan arızaları gruplamak, bir çıktının beklenen
şekle uyup uymadığını kabaca elemek — bunlar girdisi büyük, çıktısı iç kullanım
olan işlerdir ve yerel modele gider.

Bulgu, geçti/kaldı kararı ve karta yazılan metin **gitmez**: yerel modelin
ürettiği bir iddia kanıt değildir, ve ölçülmüş sınırları var.

Sınırları ezberden uygulama, **wiki'den oku**: `docs/llm/INDEX.md`. Orada hangi
işin devredilebileceği, girdinin ne kadarında modelin sessizce yanlış cevap
vermeye başladığı ve sunucunun nasıl çalıştırıldığı yazılı.

Kullanmak için **izin isteme**. Önce sunucunun durumuna bak: çalışıyorsa
kullan, çalışmıyorsa başlat. İş bitince **yalnız sen başlattıysan** durdur —
zaten çalışıyorduysa dokunma, başkası kullanıyor olabilir.

## Kayıt — wiki'ye, projeye değil

Spike'ın bulgusu projeye ait değildir: aynı araç başka bir projede de sorulur.
Kayıt **wiki**ye gider; wiki'nin yeri global `CLAUDE.md`'de tanımlıdır (bugün
`~/workspace/cc-workspace/docs/spike/`).

```
<wiki>/spike/INDEX.md              ne neyi ölçüyor — tek tablo
<wiki>/spike/<ad>/card.md          kart
<wiki>/spike/<ad>/setup.sh         ORTAMI kuran ve söken script
<wiki>/spike/<ad>/measure.sh       ÖLÇÜMÜ yapan script
<wiki>/spike/<ad>/evidence/        ham çıktılar, tarihli, silinmez
```

**`setup.sh` ile `measure.sh` neden ayrı.** Ortamı kurmak ölçümden pahalıdır ve
her tekrarda yeniden keşfedilir: hangi imaj, hangi ağ, hangi sürüm, hangi
yapılandırma, neyin neye bağlandığı. Bir kez script'e yazılırsa ikinci spike o
keşfi hiç yapmaz, ve aynı ortamı gerektiren başka bir spike onu doğrudan
çağırır. Script idempotent olmalı ve söken yolu da taşımalı — bırakılan artık,
bir sonraki koşunun ölçtüğü şeye karışır.

**`INDEX.md`** her spike için tek satır tutar; okuyanın kartı açmadan "bu soru
sorulmuş mu" diye bakabildiği yer burasıdır:

| spike | aday + sürüm | ne ölçüyor | kurulan teknolojiler | sonuç | tarih |
|---|---|---|---|---|---|
| `<ad>` | araç x.y | tek cümlelik soru | `setup.sh` neyi ayağa kaldırıyor | KABUL / RED / ÖLÇÜLEMEDİ | YYYY-MM-DD |

*Kurulan teknolojiler* sütunu arama içindir: yeni bir spike'ın ihtiyacı olan
ortamı daha önce kimin kurduğu buradan görülür ve o `setup.sh` kopyalanır.

Yeni bir dış davranış sorusuyla karşılaştığında **önce `INDEX.md`'ye bak**.
Kayıt varsa ve bayat değilse spike açma, ona bağlan.

`card.md` şunları taşır:

- **Aday** — araç/servis adı **ve sürümü**
- **Soru** — doğrulanacak iddia, tek cümle
- **Ortam** — ölçümün hangi ortamda yapıldığı, ve `setup.sh` neyi kuruyor
- **Bulgular** — her biri bir çıktıya ya da kaynağa bağlı. Dayanağı olmayan
  çıkarım `YORUM:` ile işaretlenir ve **bulgu sayılmaz**
- **Kısıtlar** — ölçüm sırasında çıkan sınırlar, tuzaklar
- **Sonuç** — `KABUL` · `RED` · `ÖLÇÜLEMEDİ`, tarihiyle
- **Geçerlilik** — ortam ya da sürüm değişirse bu kart **bayat**tır ve yeniden
  koşulmadan kullanılamaz

## Kurulum bilgisi araç başına birikir

`setup.sh` *nasıl* kurulduğunu taşır ama *neden* öyle kurulduğunu ve nerede
tökezlendiğini taşımaz. Kurulum çoğu zaman spike'ın kendisinden uzun sürer, ve
o süre tamamen yeniden keşfe gider: hangi sürüm indirilir, hangi ayar hangi
hatayı çözer, neyin yanlış olduğu nasıl anlaşılır.

Bu yüzden kurulum bilgisi wiki'ye **araç başına bir belge** olarak yazılır ve
spike'tan spike'a birikir:

- Nereden indirildiği ve **hangi sürüm**
- Kurulum adımları, koşulabilir hâliyle
- Yapılan her ayar ve **neden yapıldığı** — gerekçesiz ayar, sonraki okuyucunun
  silmeye cesaret edemediği ayardır
- **Alınan hatalar ve doğrusu**: ne denendi, ne patladı, çözüm neydi

Aynı aracı kullanan ikinci bir spike **yeni belge açmaz**, o belgeye ekler:
farklı bir ayar denediyse onu, yeni bir tuzağa düştüyse onu. Bir araç hakkında
bilinen her şey tek yerde toplanır.

Belgeyi açarken ve indeksi tazelerken wiki'nin kendi araçlarını kullan; kuralları
ve araçları wiki'nin `README`'sindedir.

## Bittiğinde

- Karar, karta **bağlanır**. Bağlanmayan karar gerekçesizdir.
- Spike koşulamadıysa (`ÖLÇÜLEMEDİ`) karar **kapanmaz**; ölçüm borcu olarak
  kalır. "Spike açılacak" demek karar vermek değildir.
- Spike'ın kodu ürüne karışmaz ve ürünü import etmez. Kabul edilen bir spike'ın
  kodu ürün kodu yerine geçmez — öğrendiğini ürüne yazmak ayrı bir iştir.
