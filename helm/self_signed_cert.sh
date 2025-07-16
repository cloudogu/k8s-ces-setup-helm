openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
    -subj "/C=DE/ST=Lower Saxony/L=Brunswick/O=$1/OU=$1/CN=$2" \
    -keyout ../target/cert.key -out ../target/cert.crt
