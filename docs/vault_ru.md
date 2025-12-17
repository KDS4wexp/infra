# Подготовка Hashi Vault для инфраструктуры:
1. Раскомментируйте блок "Core" Terraform в main.tf
><span style="color: rgba(255, 255, 255, 0.3);">Используя Hashi Vault приходится разворачивать инфраструктуру в 2 итерации, потому что распечатывание хранилища требует ручного управления</span>

2. Сделайте commit и push в окружение
```bash
git add terraform/main.tf
git commit -m "infra: core up"
git push origin dev
```
><span style="color: rgba(255, 255, 255, 0.3);">В примере используется ветка dev как окружение dev</span>

3. Подключитесь к хосту Vault
```bash
ssh -J debian@bastion.kds4wexp1.ru debian@vault.private
```

4. Произведите init:
  ``` bash
  vault operator init
  ```