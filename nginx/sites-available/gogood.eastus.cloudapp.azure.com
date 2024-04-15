# Configuração do servidor HTTPS
server {
    listen 443 ssl;
    server_name gogood.eastus.cloudapp.azure.com;

    # Caminho para o certificado SSL e chave privada
    ssl_certificate /etc/letsencrypt/live/gogood.eastus.cloudapp.azure.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/gogood.eastus.cloudapp.azure.com/privkey.pem;

    # Configuração do Proxy Reverso
    location / {
        proxy_pass http://localhost:8080; # Endereço do backend Spring Boot
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Port $server_port;
    }
}
# Configuração do servidor HTTP para redirecionar para HTTPS
server {
    listen 80;
    server_name gogood.eastus.cloudapp.azure.com;

    # Redireciona todas as solicitações HTTP para HTTPS
    return 301 https://$host$request_uri;
}
