# Инфра

## Описание:
Данный репозиторий предназначен для развертывания инфраструктуры и стека инструментов с целью обучения.

## Стек технологий:
- Ansible
- Terraform (Yandex Cloud)
- Kubernetes
- Github actions
- GitLab
- Hashi Vault
- HAProxy

## Как этим пользоваться:

### 1. Сделайте форк или клон этого репозитория: 

### 2. Создайте пары ssh ключей на своей машине:
``` bash
ssh-keygen -t rsa -b 4096
```
### 3. [Создайте S3 хранилище](https://yandex.cloud/ru/docs/storage/operations/buckets/create) для хранения состояния инфраструктуры.

### 4. [Создайте сервисный аккаунт](https://yandex.cloud/ru/docs/iam/operations/sa/create) с ролью **editor** для доступа к S3 хранилищу и [сгенерируйте статический ключ](https://yandex.cloud/ru/docs/iam/operations/authentication/manage-access-keys#create-access-key).

### 5. Добавьте секреты в GitHub:
В Environment secrets:
```
- FOLDER            "id каталога"
```
> Укажите id каталога для соответствующего окружения, например окружение dev с id каталога для dev инфраструктуры в облаке и тд. Поддерживается множество FOLDER для разных окружений.

В Repository secrets:
```
- TOKEN             "IAM token"
- CLOUD             "id облака"
- BUCKET            "Имя s3 хранилища"
- ACCESS_KEY        "Сгенерированный ключ доступа"
- SECRET_KEY        "Сгенерированный секретный ключ "
- DOMAIN            "Ваш домен для сервиса сертификации"
- PUBLIC_SSH_KEY    "Публичный SSH ключ"
```

### 6. Сделайте слияние ветки init в dev
- Перейдите в свой репозиторий в GitHub и откройте вкладку Pull request
- Откройте pull_request нажав кнопку New pull request
- Выберите base: dev <- compare: init
- Создайте pull request и одобрите его, удалив при этом ветку init
## После проделанных этапов должна развернуться инфраструктура

