vindicia_cert_file = 'config/certs/'
vindicia_cert_file += Rails.env.production? ? "soap.vindicia.com-2019.crt" : "soap.prodtest.sj.vindicia.com-2018.crt"

VINDICIA_CERT_FILE = vindicia_cert_file
