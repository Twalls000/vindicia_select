VINDICIA_SELECT_SITES = YAML.load_file("#{Rails.root}/config/vindicia_select_sites.yml").map(&:symbolize_keys)
