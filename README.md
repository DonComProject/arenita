## README

# Arenita Project 🏝️

Welcome to the **Arenita** project repository. This project contains various scripts and Ansible playbooks for installing development, graphic design, educational, and multimedia tools.

## Content 📂

| Directory       | Description                                                 |
|-----------------|-------------------------------------------------------------|
| `src/ansible`   | Ansible playbooks for installing various tools.             |
| `src/conf`      | Configuration files used in the project.                    |
| `src/guide`     | Project guides and documentation.                           |
| `src/iso-conf`  | ISO configurations for automated installations.             |
| `src/ldif`      | LDIF files for configuring LDAP users.                      |
| `src/programs`  | Scripts for installing specific programs.                   |
| `src/scripts`   | Automation scripts for various tasks.                       |

## Requirements 🛠️

- Ubuntu 22.04 LTS
- Ansible 2.9+
- Internet access

## Installation 🔧

1. Clone the repository:
   ```bash
   git clone https://github.com/DonComProject/arenita
   cd arenita
   ```
2. Run the playbooks according to your needs:
   ```bash
   ansible-playbook src/ansible/desarrollo.yml -k -b -K
   ansible-playbook src/ansible/diseno_grafico.yml -k -b -K
   ansible-playbook src/ansible/educacion.yml -k -b -K
   ansible-playbook src/ansible/multimedia.yml -k -b -K
   ```

## License 📄

This project is licensed under the MIT License. See the `LICENSE` file for more details.
