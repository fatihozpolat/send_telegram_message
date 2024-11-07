#!/bin/bash

# Renk kodları
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Kurulum dizini
INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="send_telegram_message"
CONFIG_DIR="$HOME/.config/telegram_sender"
CONFIG_FILE="$CONFIG_DIR/config"

# Banner gösterimi
echo -e "${BLUE}"
echo "=================================="
echo "  Telegram Mesaj Gönderici Kurulum"
echo "=================================="
echo -e "${NC}"

# Gerekli dizinleri oluştur
mkdir -p "$CONFIG_DIR"

# Kullanıcıdan bilgileri al
echo -e "${GREEN}Lütfen Telegram Bot Token'ınızı girin:${NC}"
read -p "> " BOT_TOKEN

echo -e "${GREEN}Lütfen Chat ID'nizi girin:${NC}"
read -p "> " CHAT_ID

# Configürasyon dosyasını oluştur
echo "BOT_TOKEN=$BOT_TOKEN" > "$CONFIG_FILE"
echo "CHAT_ID=$CHAT_ID" >> "$CONFIG_FILE"
chmod 600 "$CONFIG_FILE"

# Ana script içeriği
cat > /tmp/$SCRIPT_NAME << 'EOL'
#!/bin/bash

CONFIG_FILE="$HOME/.config/telegram_sender/config"

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Configürasyon dosyasını kontrol et
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}Hata: Configürasyon dosyası bulunamadı!${NC}"
    exit 1
fi

# Configürasyonu yükle
source "$CONFIG_FILE"

# Telegram Bot API kullanarak mesaj gönderme fonksiyonu
send_telegram_message() {
    local MESSAGE="$1"

    # URL encode message
    MESSAGE=$(echo "$MESSAGE" | curl -Gso /dev/null -w %{url_effective} --data-urlencode @- "" | cut -c 3-)

    # Send message
    RESPONSE=$(curl -s \
        --data "chat_id=$CHAT_ID" \
        --data "text=$MESSAGE" \
        "https://api.telegram.org/bot$BOT_TOKEN/sendMessage")

    if echo "$RESPONSE" | grep -q '"ok":true'; then
        echo -e "${GREEN}✔ Mesaj başarıyla gönderildi${NC}"
    else
        echo -e "${RED}✘ Mesaj gönderilemedi${NC}"
        echo "Hata: $RESPONSE"
    fi
}

# Parametre kontrolü
if [ $# -eq 0 ]; then
    echo "Kullanım: $0 <MESAJ>"
    echo "Örnek: $0 'Merhaba Dünya!'"
    exit 1
fi

send_telegram_message "$*"
EOL

# Scripti kurulum dizinine taşı
echo "Script kuruluyor..."
sudo mv /tmp/$SCRIPT_NAME $INSTALL_DIR/
sudo chmod +x $INSTALL_DIR/$SCRIPT_NAME

echo -e "${GREEN}"
echo "✔ Kurulum tamamlandı!"
echo "--------------------------------"
echo "Kullanım:"
echo "send_telegram_message 'Mesajınız'"
echo -e "${NC}"

# Test mesajı gönder
echo -e "${BLUE}Test mesajı göndermek ister misiniz? (E/h)${NC}"
read -p "> " TEST_SEND

if [[ $TEST_SEND =~ ^[Ee]$ ]] || [[ -z $TEST_SEND ]]; then
    $INSTALL_DIR/$SCRIPT_NAME "Test mesajı - Kurulum başarılı!"
fi
