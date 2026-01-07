# Ansible Role: {{ role.name }}

{% if role.meta and role.meta.galaxy_info and role.meta.galaxy_info.description %}
{{ role.meta.galaxy_info.description }}
{% else %}
No description available
{% endif %}

## Table of Contents

- [Requirements](#requirements)
- [Dependencies](#dependencies)
- [Role Variables](#role-variables)
- [Task Overview](#task-overview)
- [Example Playbook](#example-playbook)
- [Documentation Maintenance](#documentation-maintenance)
- [License](#license)
- [Author Information](#author-information)

## Requirements

{% if role.meta and role.meta.galaxy_info %}
{% if role.meta.galaxy_info.min_ansible_version %}
- Ansible >= {{ role.meta.galaxy_info.min_ansible_version }}
{% else %}
- Ansible >= 2.9
{% endif %}
{% if role.meta.galaxy_info.platforms %}
- Supported platforms:
{%- for platform in role.meta.galaxy_info.platforms %}
  - {{ platform.name }}{% if platform.versions %} ({{ platform.versions | join(', ') }}){% endif %}
{%- endfor %}
{% endif %}
{% else %}
- Ansible >= 2.9
{% endif %}

## Dependencies

{% if role.meta and role.meta.galaxy_info and role.meta.galaxy_info.documented_requirements and role.meta.galaxy_info.documented_requirements | length > 0 %}
This role requires the following roles and collections:

{% set ext_roles = [] %}
{% set ext_collections = [] %}
{% for dep in role.meta.galaxy_info.documented_requirements %}
  {% if dep.src %}
    {% set _ = ext_roles.append(dep) %}
  {% elif dep.name %}
    {% set _ = ext_collections.append(dep) %}
  {% endif %}
{% endfor %}

{% if ext_roles %}
**Roles:**
{% for role_dep in ext_roles %}
- [{{ role_dep.name | default(role_dep.src.split('/')[-1].replace('.git', '')) }}]({{ role_dep.src }}){% if role_dep.version %} (version: {{ role_dep.version }}){% endif %}
{% endfor %}
{% endif %}

{% if ext_collections %}
**Collections:**
{% for collection in ext_collections %}
- `{{ collection.name }}`{% if collection.version %} (>= {{ collection.version }}){% endif %}
{% endfor %}
{% endif %}

To install all dependencies:
```bash
ansible-galaxy install -r meta/install_requirements.yml
```
{% else %}
No dependencies defined.

To install external requirements:
```bash
ansible-galaxy install -r meta/install_requirements.yml
```
{% endif %}

## Role Variables

{% if role.defaults %}
{% for file in role.defaults %}
### File: `defaults/{{ file.file }}`

| Variable | Type | Default Value | Description |
|----------|------|---------------|-------------|
{%- for var, data in file.data.items() %}
{%- if '.' not in var %}
{%- if data.type in ['dict', 'list'] %}
{%- set has_children = namespace(found=false) %}
{%- for child_var in file.data.keys() %}
{%- if child_var.startswith(var ~ '.') %}
{%- set has_children.found = true %}
{%- endif %}
{%- endfor %}
{%- set value_str = data.value | string | trim %}
{%- set is_empty = (value_str == '[]' or value_str == '{}') and not has_children.found %}
| [`{{ var }}`](defaults/{{ file.file }}#L{{ data.line | default('') }}) | {{ data.type | default('str') }} | {{ '`[]`' if data.type == 'list' and is_empty else ('`{}`' if data.type == 'dict' and is_empty else 'See below') }} | {{ data.description | default('_No description provided_') }} |
{%- else %}
| [`{{ var }}`](defaults/{{ file.file }}#L{{ data.line | default('') }}) | {{ data.type | default('str') }} | `{{ data.value }}` | {{ data.description | default('_No description provided_') }} |
{%- endif %}
{%- endif %}
{%- endfor %}

{%- for var, data in file.data.items() %}
{%- if '.' not in var and data.type in ['dict', 'list'] %}
{%- set has_children = namespace(found=false) %}
{%- for child_var in file.data.keys() %}
{%- if child_var.startswith(var ~ '.') %}
{%- set has_children.found = true %}
{%- endif %}
{%- endfor %}
{%- set value_str = data.value | string | trim %}
{%- set is_empty = (value_str == '[]' or value_str == '{}') and not has_children.found %}
{%- if not is_empty %}

#### `{{ var }}`

```yaml
{%- if has_children.found %}
{%- set indices = namespace(list=[]) %}
{%- for child_var in file.data.keys() %}
{%- if child_var.startswith(var ~ '.') %}
{%- set parts = child_var.replace(var ~ '.', '').split('.') %}
{%- if parts[0].isdigit() and parts[0] not in indices.list %}
{%- set _ = indices.list.append(parts[0]) %}
{%- endif %}
{%- endif %}
{%- endfor %}
{%- for idx in indices.list | sort %}
- {% set item_keys = namespace(keys=[]) %}{% for child_var in file.data.keys() %}{% if child_var.startswith(var ~ '.' ~ idx ~ '.') %}{% set key = child_var.replace(var ~ '.' ~ idx ~ '.', '').split('.')[0] %}{% if key not in item_keys.keys %}{% set _ = item_keys.keys.append(key) %}{% endif %}{% endif %}{% endfor %}{% for key in item_keys.keys %}{% set full_key = var ~ '.' ~ idx ~ '.' ~ key %}{% if loop.first %}{{ key }}:{% else %}  {{ key }}:{% endif %} {% if file.data[full_key].type == 'list' %}{% for sub_child_var, sub_child_data in file.data.items() %}{% if sub_child_var.startswith(full_key ~ '.') and sub_child_var.replace(full_key ~ '.', '').isdigit() %}
    - {{ sub_child_data.value }}{% endif %}{% endfor %}
{% else %}{{ file.data[full_key].value }}
{% endif %}{% endfor %}
{%- endfor %}
{%- else %}
{{ data.value }}
{%- endif %}
```
{%- endif %}
{%- endif %}
{%- endfor %}

{% endfor %}
{% else %}
No default variables defined.
{% endif %}

## Task Overview

{% if role.tasks %}
This role performs the following tasks:

{% for task_file in role.tasks %}
### File: `tasks/{{ task_file.file }}`

| Task Name | Module | Has Conditions | Line |
|-----------|--------|----------------|------|
{%- for task in task_file.tasks %}
{%- if task.name %}
| [{{ task.name }}](tasks/{{ task_file.file }}#L{{ task.line | default('') }}) | {{ task.module | default('N/A') }} | {{ 'Yes' if task.when or task.block else 'No' }} | {{ task.line | default('N/A') }} |
{%- endif %}
{%- endfor %}

{% if task_file.tasks | selectattr('description', 'defined') | list | length > 0 %}
**Task Details:**
{% for task in task_file.tasks %}
{%- if task.name and task.description %}
- **{{ task.name }}**: {{ task.description }}
{%- endif %}
{%- endfor %}
{% endif %}

{% endfor %}
{% else %}
No tasks documented.
{% endif %}

## Example Playbook

```yaml
---
- hosts: all
  become: yes
  roles:
    - role: {{ role.name }}
{% if role.defaults and role.defaults[0].data %}
      vars:
{%- for var, data in (role.defaults[0].data.items() | list)[:3] %}
        {{ var }}: {{ data.value }}
{%- endfor %}
{% endif %}
```

## License

{% if role.meta and role.meta.galaxy_info and role.meta.galaxy_info.license %}
{{ role.meta.galaxy_info.license }}
{% else %}
MIT
{% endif %}

## Author Information

{% if role.meta and role.meta.galaxy_info and role.meta.galaxy_info.author %}
**Author:** {{ role.meta.galaxy_info.author }}
{% else %}
**Author:** Gorkem Korkmaz
{% endif %}

{% if role.meta and role.meta.galaxy_info and role.meta.galaxy_info.company %}
**Company:** {{ role.meta.galaxy_info.company }}
{% endif %}

**GitHub:** [gkorkmaz](https://github.com/gkorkmaz)

---
*This documentation was automatically generated using [docsible](https://github.com/zbohm/docsible).*
