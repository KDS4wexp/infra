# Простая инфраструктура

## Описание:
Данный репозиторий предназначен для развертывания простой инфраструктуры для небольших проектов.

## Стек технологий:
- Ansible
- Terraform (Yandex Cloud)
- GitLab
- Hashi Vault
- HAProxy

## Как этим ползоваться:

### 1. Сделайте форк этого репозитория или склонируйте репозиторий: 
Форк можно сделать по кнопке справа вверху в репозитории Github
``` bash
    git clone https://github.com/KDS4wexp/infra.git
```

### 2. Создайте пары ssh ключей на своей машине:
``` bash
ssh-keygen -t rsa -b 4096
```
### 3. [Создайте S3 хранилище](https://yandex.cloud/ru/docs/storage/operations/buckets/create) для хранения состояния инфраструктуры.

### 4. [Создайте сервисный аккаунт](https://yandex.cloud/ru/docs/iam/operations/sa/create) с ролью **editor** для доступа к S3 хранилищу и [сгенерируйте статический ключ](https://yandex.cloud/ru/docs/iam/operations/authentication/manage-access-keys#create-access-key).

### 5. Добавьте секреты в GitHub:
- TOKEN "Ваш IAM token"
- CLOUD "Ваш идентификатор облака"
- FOLDER "Ваш идентификатор каталога"
- BUCKET "Ваше имя s3 хранилища"
- ACCESS_KEY "Ваш сгенерированный ключ доступа"
- SECRET_KEY "Ваш сгенерированный секретный ключ "
- DOMAIN "Ваш домен для сервиса сертификации"
- PUBLIC_SSH_KEY "Ваш публичный SSH ключ"

### 6. Сделайте слияние ветки init в dev
- Перейдите в свой репозиторий в GitHub и откройте вкладку Pull request
- Откройте pull_request нажав кнопку New pull request
- Выберите base: dev <- compare: init
- Создайте pull request и одобрите его, удалив при этом ветку init
## После проделанных этапов должна развернуться инфраструктура

