#!/bin/bash

# =================================================================
# PROJE: Pardus Gelişmiş PDF Optimizasyon ve Sıkıştırma Paneli
# ÖZELLİKLER: Kalite Seçimi, İstatistikler, Loglama ve Bağımlılık Kontrolü
# =================================================================

# --- BAĞIMLILIK KONTROLÜ ---
check_dependencies() {
    for cmd in gs yad whiptail; do
        if ! command -v $cmd &> /dev/null; then
            echo "Hata: $cmd yüklü değil. Lütfen 'sudo apt install $cmd' komutunu çalıştırın."
            exit 1
        fi
    done
}

# --- FONKSİYONLAR ---

# 1. Log Tutma Fonksiyonu
log_islem() {
    local mesaj="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $mesaj" >> pdf_islem_gecmisi.log
}

# 2. Boyut Hesaplama ve İstatistik
goster_istatistik() {
    local eski_boyut=$(du -h "$1" | cut -f1)
    local yeni_boyut=$(du -h "$2" | cut -f1)
    local mesaj="İşlem Tamamlandı!\n\nOrijinal Boyut: $eski_boyut\nYeni Boyut: $yeni_boyut"
    
    if [[ "$3" == "gui" ]]; then
        yad --title="Sonuç" --text="$mesaj" --button="Tamam:0" --center
    else
        whiptail --title="Sonuç İstatistikleri" --msgbox "$mesaj" 12 60
    fi
}

# 3. Grafik Arayüz (GUI - YAD)
calistir_gui() {
    KALITE=$(yad --title="Kalite Seçin" --list --column="Ayar" --column="Açıklama" \
        "/screen" "Düşük Kalite (72 dpi)" "/ebook" "Orta Kalite (150 dpi)" "/printer" "Yüksek Kalite (300 dpi)" \
        --center --width=400 --height=250)
    [[ -z "$KALITE" ]] && return
    KALITE_VAL=$(echo $KALITE | cut -d'|' -f1)

    GIRIS=$(yad --title="PDF Seç" --file --file-filter="*.pdf" --center --width=500)
    [[ -z "$GIRIS" ]] && return

    CIKIS=$(yad --title="Kaydet" --file --save --file-filter="*.pdf" --center)
    [[ -z "$CIKIS" ]] && return

    gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=$KALITE_VAL \
       -dNOPAUSE -dQUIET -dBATCH -sOutputFile="$CIKIS" "$GIRIS"

    log_islem "GUI: $GIRIS sıkıştırıldı -> $CIKIS ($KALITE_VAL)"
    goster_istatistik "$GIRIS" "$CIKIS" "gui"
}

# 4. Terminal Arayüzü (TUI - Whiptail)
calistir_tui() {
    KALITE=$(whiptail --title "Kalite Ayarı" --menu "Sıkıştırma seviyesini seçin:" 15 60 3 \
        "/screen" "En Küçük Boyut (Düşük Kalite)" \
        "/ebook" "Standart (Orta Kalite)" \
        "/printer" "Yüksek Çözünürlük" 3>&1 1>&2 2>&3)
    [[ -z "$KALITE" ]] && return

    GIRIS=$(whiptail --inputbox "PDF dosyasının tam yolunu girin:" 10 60 3>&1 1>&2 2>&3)
    [[ ! -f "$GIRIS" ]] && return

    CIKIS="sikistirilmis_$(basename "$GIRIS")"
    
    gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=$KALITE \
       -dNOPAUSE -dQUIET -dBATCH -sOutputFile="$CIKIS" "$GIRIS"

    log_islem "TUI: $GIRIS sıkıştırıldı -> $CIKIS ($KALITE)"
    goster_istatistik "$GIRIS" "$CIKIS" "tui"
}

# --- ANA PROGRAM AKIŞI ---
check_dependencies
MENU=$(whiptail --title "Pardus PDF Master v2.0" --menu "Çalışma Modunu Seçin" 15 60 2 \
    "1" "Grafik Arayüz (GUI - YAD)" \
    "2" "Terminal Arayüz (TUI - Whiptail)" 3>&1 1>&2 2>&3)

[[ $? -ne 0 ]] && exit 0

[ "$MENU" = "1" ] && calistir_gui || calistir_tui