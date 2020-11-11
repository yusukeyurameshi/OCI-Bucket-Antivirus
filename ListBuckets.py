#!/bin/python3

from dotenv import load_dotenv

load_dotenv()

def create_signer():
    # assign default values
    config_file = oci.config.DEFAULT_LOCATION
    config_section = oci.config.DEFAULT_PROFILE

    try:
        signer = oci.auth.signers.InstancePrincipalsSecurityTokenSigner()
        config = {'region': signer.region, 'tenancy': signer.tenancy_id}
        return config, signer
    except Exception:
        print_header("Error obtaining instance principals certificate, aborting", 0)
        raise SystemExit
    return config, signer

def Main():
    config, signer = create_signer()

Main()