import requests
def get_iam(OAuthToken):
      url = "https://iam.api.cloud.yandex.net/iam/v1/tokens"
      json = {
        "yandexPassportOauthToken": OAuthToken
      }
      iam = requests.post(url, json=json)
      return print(iam)

get_iam("y0_AgAAAABz0WuYAATuwQAAAAEBFJ-uAAApfYLGMO9CtI-HWoXEorGRIBm7xg")