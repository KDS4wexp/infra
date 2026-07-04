# -*- coding: utf-8 -*-

# Copyright (c) 2025 Ansible Project
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

DOCUMENTATION = r"""
name: yandex_cloud
author:
  - Kalashnikov Dmitry (@KDS4wexp)
short_description: Builds Yandex Cloud inventory using the REST API
description:
version_added: 2.19.0
requirements:
  - requests
options:
  token:
    description: OAuth or IAM token
    type: str
    required: true
  folders:
    description: Folder Yandex Cloud
    type: list
    elements: str
    reqired: true
  labels:
    description: Labels to be able to find specific instances
    type: list
    elements: str 
    
"""

EXAMPLE = r"""
""" 

import requests
from ansible.plugins.inventory import BaseInventoryPlugin

class InventoryModule(BaseInventoryPlugin):

    NAME = 'yandex_ec2'  
    INVENTORY_FILE_SUFFIXES = ("yandex_ec2.yml", "yandex_ec2.yaml")

    def get_iam(self, OAuthToken):
      url = "https://iam.api.cloud.yandex.net/iam/v1/tokens"
      data = {
        "yandexPassportOauthToken": OAuthToken
      }
      iam = requests.post(url, data)
      return iam.json()[iamToken]

    def get_instances_list(self, iamToken,  folders):
      url = "https://compute.api.cloud.yandex.net/compute/v1/instances"
      headers = "Authorization: Bearer {iamToken}"
      params = "folderId: {floders}"
      instances = requests.get(url, headers, params)
      return instances

    def get_instance_ip(self):
      url = "https://compute.api.cloud.yandex.net/compute/v1/instances/{instanceId}"

      

    def parse(self, inventory, loader, path, cache=True):
        super().parse(inventory, loader, path, cache=cache)

        token = self.get_option("token")
        folders = self.get_option("folders")
        labels = self.get_option("labels")



        self.loader = loader
        self.inventory = inventory
        self.templar = Templar(loader=loader)