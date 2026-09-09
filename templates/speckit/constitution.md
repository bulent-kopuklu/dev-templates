<!--
Çekirdek ilkeler. Bunlar her projede geçerlidir; projeye özel ilkeler VII'den
itibaren ALTINA eklenir. Buradaki maddeler silinmez, yalnız Yönetişim
bölümündeki usulle değiştirilir.
-->

# Anayasa

## Core Principles

### I. Kanıtsız Teknik İddia Yasak

Bir teknolojinin uygunluğu ancak çalıştırılıp ölçülerek; bir garanti ancak ihlal
denemesi yapılıp başarısız olduğu görülerek kabul EDİLİR. Dokümandan okunarak
edinilen rakam bir karar gerekçesi OLAMAZ; modelin eğitim bilgisinden gelen bir
davranış iddiası hiç olamaz — hangi sürümün davranışı olduğu bilinmez.

Kanıt üreten deneyin nasıl tekrarlanacağı **ve nerede durduğu** yazılı olmak
ZORUNDADIR. Yeri olmayan kural yazılmaz: dış dünyanın davranışına dayanan bir
iddia kurulduğu anda üç yoldan biri zorunludur —

- **(a)** kayıt zaten var → ona bağlanır,
- **(b)** burada doğrulanabilir → ölçülür, sürüm ve tarihle yazılır, bağlanır,
- **(c)** doğrulanamaz → **iddia kurulamaz**; ölçüm borcu yazılır ve iddiaya
  dayanan iş "tamam" sayılmaz.

Gerekçe: Belgelenen davranış ile gözlenen davranış ayrışır; kararı yalnızca
gözlenen taşır. Ve yazılmayan ölçüm bir sonraki soruda yeniden sorulur.

### II. Ölçüm Önce Kendini Kanıtlar

Her ölçümün bir **kontrolü** OLMAK ZORUNDADIR: pozitif kontrol ölçüm noktasının
canlı olduğunu, negatif kontrol iddianın yanlışlanabildiğini gösterir.
**Kontrolü olmayan ölçüm başarısız sayılır** — hiçbir şey ölçmeyen bir sayaç da
sıfır gösterir.

Bir koşu, **ölçebildiğini göstermeden ölçtüğünü iddia EDEMEZ**; buna başlangıç
durumu da dahildir. Bozuk bir düzenekte başlayan koşu, ölçtüğünü değil
düzeneğini raporlar. Ölçüm çıktısı üretilmediyse sonuç sıfır değil **hata**dır.

Sonuç kümesi ikili değil üçlüdür: **geçti · kaldı · ölçülemedi**. Ölçülemeyen
bir durumu geçti ya da kaldı diye kaydetmek, ikisi de yalan olduğu için
yasaktır.

Gerekçe: Ölçüm arızalarının neredeyse tamamı **ölçülen şeyin sonucu gibi
görünür** ve sessizce kabul edilir. En tehlikelisi doğru sayının yanlış sorunun
cevabı olmasıdır: kayıtta hakiki bir ölçüm gibi durur.

### III. Kanıt Ölçtüğü Şeyin İçinden Çıkmaz

Ölçen kod ürün kodunu **import ETMEZ** ve durumu DEĞİŞTİRMEZ. Doğrulayan taraf
doğrulanan taraf olamaz.

Bundan üç ayrım doğar ve bir dosyanın hangisi olduğu bulunduğu dizinden
anlaşılır: üretimde koşan kod, kurulumu bir kez yapan kod, ve ölçen kod.
**Test kanıt değildir**: birim test kodun kendi doğruluğunu sınar, kanıt kapısı
ürünün dış dünyaya verdiği sözü sınar ve negatif kontrolü olmak ZORUNDADIR.

Gerekçe: Ürün kodu değiştiğinde kanıtın da değişmesi, kanıtı ürünün bir
görüşüne çevirir.

### IV. Tek Kaynak Spec

Üretilen artefaktların tek kaynağı **spec**tir. Ön çalışma belgeleri, tasarım
notları ve feature listeleri spec'in **girdisi**dir; spec yazıldıktan sonra
kaynak değil, arşiv bile değildir — hiçbir kontrol onlara sormaz, hiçbir
artefakt onlara atıf yapmaz.

Bir kararın gerekçesi spec'te yoksa **yoktur**; başka bir belgede olabileceği
varsayılamaz. Spec ve plan, girdilerinin taşıdığı bilgiyi **aşmak** zorundadır:
aşmıyorsa ya girdinin yarısı çöptü ya spec eksik yazıldı, ve ikisi de kayıttır.

Gerekçe: İki kaynak arasında senkron tutmak, tek kaynak ile kod arasında
senkron tutmaktan pahalıdır; üçüncü kaynak onu imkânsız yapar.

### V. Önce Sadelik

Problemi çözen en az bileşen seçilir. Halihazırda olgun bir çözümün yaptığı iş
yeniden yazılmaz. Spekülatif esneklik, yapılandırılabilirlik veya "ileride
lazım olur" bileşeni EKLENMEZ. Eklenen her bileşen, hangi somut gereksinimi
karşıladığıyla gerekçelendirilmek ZORUNDADIR.

Koşmayan bir dosya ağaçta DURMAZ. "Sonra düzeltiriz" diye tutulan bir kontrol,
hiçbir şey ölçmeden kırmızı yanar ve ölçen bir kontrolün kırmızısını
değersizleştirir. Yazılmamış olanın gerekçesi metinde durur, kodda değil.

Gerekçe: Her ek bileşen; işletme, güvenlik ve arıza yüzeyi maliyeti demektir.

### VI. Doküman Dili

Üretilen tüm doküman ve çıktı dosyaları (spec, plan, araştırma notu, task
listesi, checklist) TÜRKÇE yazılır. Şablon İngilizce olsa bile içerik Türkçe
doldurulur. Teknik terimler çevrilmez. İstisna: kod ve commit mesajları
İngilizcedir.

Gerekçe: Dokümanın okuyucusu ekiptir; okunmayan doküman yazılmamış sayılır.

## Spike

İlke I'in (b) yolu **spike**'tır: dış dünyanın davranışı hakkında bir iddiaya
ihtiyaç var, cevap hiçbir belgede yok, ve öğrenmek için ölçmek gerekiyor.
Böyle bir durumda spike **tetiklenir**. Spike'ın kendi süreci — nerede aradığı,
neyi kaydettiği, bayat bir kaydı nasıl tazelediği — spike aracının tarifindedir
ve burada tekrar edilmez. Buradan bakıldığında spike tek şey yapar: bir kanıt
kaydının **yolunu** döndürür.

Anayasanın bağladığı üç şey:

- Dış dünyanın davranışına dayanan bir iddia, arkasında bir spike kaydı olmadan
  kurulamaz. Modelin bildiğini sanması, resmî dokümanın öyle yazması ya da
  kararın daha önce böyle verilmiş olması spike'ın yerini tutmaz.
- Kararı taşıyan artefakt, dayandığı kaydın **yolunu yazar**. Yol yoksa gerekçe
  de yoktur; araştırma notundaki her dış davranış iddiası bir kayda bağlanmak
  ZORUNDADIR.
- Spike ölçemediyse karar **kapanmaz**; ölçüm borcu olarak kalır. "Spike
  açılacak" demek karar vermek değildir.

## Doğrulama Rejimi

Aşağıdakiler yalnızca çalıştırılmış bir kanıtla kapatılır; kanıt üretilmeden
ilgili iş "tamam" sayılmaz:

- **Teknoloji ve davranış iddiaları (İlke I)**: seçim gerekçesi koşulmuş bir
  ölçüme dayandırılır; ölçümün tekrar koşulma yolu, sürümü ve tarihi yazılır.
- **Her kanıt kapısı (İlke II)**: en az bir kontrolü vardır ve o kontrol kayıtta
  görünür.
- **Ölçümün geçerlilik sınırı (İlke II)**: ölçüm hangi ortamda yapıldıysa o
  yazılır. Ortam değiştiğinde ölçüm **bayattır** ve yeniden koşulmadan
  kullanılamaz — bayat bir kanıt, yanlış sebeple yeşil yanar.

## Ölçülmemiş Olanın Kaydı

Ölçülmemiş adımların listesi, ölçülmüş sonuçlar kadar bir artefakttır ve
**bu listede olmayan hiçbir şey varsayım değildir**. Her madde ne bilinmediğini
ve neden önemli olduğunu yazar.

"Yazıldı ama ölçülmedi" ayrı bir hâldir: kod derleniyor, birim testi var, ama
gerçek ortamda hiç koşmadıysa o iş **tamamlanmamıştır**. Bir işaret kutusu bunu
gösteremez.

## Geliştirme Akışı ve Kalite Kapıları

- Her spec, plan ve task, ilgili olduğu ilkelere geri izlenebilir OLMAK
  ZORUNDADIR; hiçbir ilkeye bağlanamayan iş kapsam dışıdır.
- İlke V gereği eklenen her yeni bileşen için "bunu yapan olgun bir çözüm var
  mı?" sorusu yazılı olarak cevaplanır.
- Kanıt gerektiren bir iddia (İlke I) kanıtsız kaldıysa, ilgili iş "tamamlandı"
  olarak işaretlenemez; eksik kanıt açıkça yazılır.
- Bir kontrolün "ölçemedim" hâli, "iddia doğrulandı" hâlinden ayrı raporlanır.
- Doküman dili İlke VI'ya uygun değilse çıktı kabul edilmez.

## Governance

- Bu anayasa, projedeki diğer tüm pratik ve alışkanlıkların üzerindedir.
  Çelişki hâlinde anayasa kazanır.
- **Değişiklik usulü**: Değişiklik önerisi, hangi ilkeyi neden değiştirdiğini ve
  etkilediği mevcut kararları yazılı olarak belirtir. Proje sahibi onaylamadan
  hiçbir ilke eklenemez, değiştirilemez veya kaldırılamaz.
- **Çekirdek ilkeler**: I–VI ortaktır ve projeye özel ilkeler VII'den itibaren
  eklenir. Çekirdekte yapılan bir değişiklik yalnız bu projede kalır; başka
  projelerde de geçerli olması isteniyorsa çekirdeğin kendisine taşınmalıdır,
  yoksa bir sonraki projede o madde yoktur.
- **Sürümleme**: Semantic versioning. MAJOR = geri uyumsuz ilke kaldırma/yeniden
  tanımlama; MINOR = yeni ilke veya bölüm; PATCH = açıklama ve ifade düzeltmesi.
- **Uyum denetimi**: Her spec/plan/task incelemesinde anayasa uyumu kontrol
  edilir. İlkeden sapma; ya reddedilir ya da gerekçesi ve süresi yazılı bir
  istisna olarak kaydedilir. Sessiz sapma kabul edilmez.

**Version**: 1.0.0
