# Pardus PDF Sıkıştırma Aracı (Ghostscript Frontend)
## Proje Tanıtımı ve Amacı
Bu proje, Linux ekosisteminde güçlü bir komut satırı aracı olan Ghostscript'i temel alarak, son kullanıcıların terminal karmaşasına girmeden PDF dosyalarını kolayca sıkıştırabilmesini sağlar. Proje kapsamında hem grafik kullanıcı arayüzü (GUI) hem de terminal tabanlı kullanıcı arayüzü (TUI) geliştirilmiştir. Temel amaç, Pardus üzerinde hızlı, yerli ve kullanıcı dostu bir araç sunmaktır.
## Kurulum Talimatları ve Bağımlılıklar
Uygulamanın Pardus üzerinde sorunsuz çalışabilmesi için aşağıdaki paketlerin sisteminizde yüklü olması gerekmektedir:
### Sistem Gereksinimleri
Ghostscript: PDF işleme motoru.

YAD (Yet Another Dialog): Grafiksel arayüz bileşenleri için.

Whiptail: Terminal tabanlı (TUI) arayüz bileşenleri için.
### Kurulum Komutu
Terminali açarak aşağıdaki komutu uygulayınız:
```
sudo apt update && sudo apt install ghostscript yad whiptail -y
```
### Kullanım Kılavuzu
Uygulamayı çalıştırmak için script dosyasına yetki verip başlatmanız yeterlidir:
Script'i Çalıştırılabilir Yapın:
    ```
    chmod +x pdf_araci.sh
    ```

Uygulamayı Başlatın:
```
./pdf_araci.sh
```
### Modlar:
Grafik Arayüz (GUI): YAD arayüzü ile dosya yöneticisinden seçim yapmanızı sağlar.

Terminal Arayüzü (TUI): Whiptail üzerinden metin tabanlı yönlendirmelerle çalışır.
