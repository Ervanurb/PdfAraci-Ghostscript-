#!/bin/bash

# =================================================================
# PROJE ADI: Pardus PDF Sıkıştırma Aracı (Ghostscript Frontend)
# AMAC: PDF dosyalarını optimize ederek boyutlarını küçültmek.
# TEKNIK: Bash, YAD (GUI) ve Whiptail (TUI) kullanılmıştır. 
# =================================================================

# --- AYARLAR ---
KALITE="/screen" # En yüksek sıkıştırma seviyesi

# --- FONKSİYONLAR ---

# 1. GRAFİK ARAYÜZ (GUI) - YAD 
calistir_gui() {
    # Giriş Dosyası Seçimi
    GIRIS=$(yad --title="Pardus PDF Sıkıştırıcı" \
        --window-icon="pdf" --image="pdf" \
        --text="Lütfen sıkıştırılacak PDF dosyasını seçin:" \
        --file --file-filter="PDF Dosyaları | *.pdf" \
        --center --width=500 --height=250)
    
    [[ -z "$GIRIS" ]] && return

    # Çıkış Dosyası Seçimi
    CIKIS=$(yad --title="Farklı Kaydet" \
        --window-icon="document-save" \
        --file --save --file-filter="PDF Dosyaları | *.pdf" \
        --center --width=500 --height=250)
    
    [[ -z "$CIKIS" ]] && return

    # İşlem Safhası (Progress Bar)
    (
        gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=$KALITE \
           -dNOPAUSE -dQUIET -dBATCH -sOutputFile="$CIKIS" "$GIRIS"
        echo "100"
    ) | yad --progress --pulsate --auto-close --title="İşleniyor" \
        --text="PDF optimize ediliyor, lütfen bekleyiniz..." --width=400 --center

    yad --title="Başarılı" --text="İşlem tamamlandı!\nDosya: $CIKIS" --button="Tamam:0" --center
}

calistir_tui() {
    # Giriş dosyasını al
    GIRIS=$(whiptail --title " PDF SIKIŞTIRMA (TUI) " \
        --backtitle "Pardus Linux Projesi" \
        --inputbox "Sıkıştırılacak dosyanın TAM YOLUNU girin:\n(İpucu: Dosyayı terminale sürükleyip yolu kopyalayabilirsiniz)" 12 60 3>&1 1>&2 2>&3)
    
    # Kullanıcı iptal ettiyse veya boşsa çık
    [[ -z "$GIRIS" ]] && return

    # DOSYA KONTROLÜ (Boş dosya üretimini engellemek için)
    if [ ! -f "$GIRIS" ]; then
        whiptail --title "Hata" --msgbox "Dosya bulunamadı!\nGirilen yol: $GIRIS" 10 60
        return
    fi

    # Çıkış dosyası adını al
    CIKIS=$(whiptail --title " Kayıt Yeri " \
        --inputbox "Yeni dosya adını belirleyin (uzantısı .pdf olmalı):" 12 60 "sikistirilmis_sonuc.pdf" 3>&1 1>&2 2>&3)
    
    [[ -z "$CIKIS" ]] && return

    # Ghostscript Komutu - Değişkenler mutlaka ÇİFT TIRNAK içinde olmalı
    # -dQUIET ve -dBATCH parametreleri işlemin arka planda temiz çalışmasını sağlar [cite: 22]
    gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen \
       -dNOPAUSE -dQUIET -dBATCH -sOutputFile="$CIKIS" "$GIRIS"

    # İşlem başarısını kontrol et
    if [ $? -eq 0 ] && [ -s "$CIKIS" ]; then
        whiptail --title " Başarılı " --msgbox "İşlem bitti!\nDosya Boyutu: $(du -h "$CIKIS" | cut -f1)" 10 60
    else
        whiptail --title " Hata " --msgbox "Sıkıştırma başarısız oldu veya dosya boş üretildi.\nLütfen giriş dosyasını kontrol edin." 10 60
    fi
}

# --- ANA PROGRAM AKIŞI ---

# Karşılama Ekranı
whiptail --title "Pardus PDF Optimizasyon Aracı" \
    --msgbox "Bu uygulama Ghostscript altyapısını kullanarak PDF dosyalarınızı sıkıştırır.\n\nDevam etmek için Tamam'a basın." 12 60

# Arayüz Seçim Menüsü 
SECIM=$(whiptail --title " Arayüz Seçimi " \
    --backtitle "Lütfen bir çalışma modu seçiniz" \
    --menu "Hangi arayüzü kullanmak istersiniz?" 15 60 2 \
    "1" "Grafik Arayüzü (GUI - YAD)" \
    "2" "Terminal Arayüzü (TUI - Whiptail)" 3>&1 1>&2 2>&3)

case $SECIM in
    1) calistir_gui ;;
    2) calistir_tui ;;
    *) echo "Uygulamadan çıkıldı." ;;
esac