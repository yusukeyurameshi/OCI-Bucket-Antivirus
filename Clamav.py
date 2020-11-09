import os, oci, subprocess
from oci.config import validate_config
#from dotenv import load_dotenv
from base64 import b64decode, b64encode

instance_dict = {}

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


def streamingEnv():
    streamingID = 'ocid1.stream.oc1.sa-saopaulo-1.amaaaaaaytuymbaaxamd7su6xeaoyvnlus7ku4nccmdbtznnspamfcqong3q'
    endpoint = "https://cell-1.streaming.sa-saopaulo-1.oci.oraclecloud.com"

    streaming = oci.streaming.StreamClient(config, signer=signer)


def readMessages(streamingID):
    cursor_detail = getCursor()
    cursor = streaming.create_cursor(streamingID, cursor_detail)
    r = streaming.get_messages(streamingID, cursor.data.value)

    if len(r.data):
        for message in r.data:
            file = b64decode(message.value).decode('utf-8')
            execClamAV(file)

def getCursor():
    cursor = oci.streaming.models.CreateCursorDetails()
    cursor.partition = "0"
    cursor.type = "TRIM_HORIZON" #consume all messages in a stream
    return cursor

def decodeByte(data, code='UTF-8'):
    return bytes(data).decode(code)

def execClamAV(file):
    print("Checando arquivo %s" %file)
    command = "curl '{}' | clamdscan -".format(file)
    process = subprocess.Popen(command,shell=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
    for line in decodeByte(process.communicate()[0]).split("\n"):
        if "Infected files: 1" in line:
            print('Arquivo Contaminado!')
        elif "Infected files: 0" in line:
            print('Arquivo nao contaminado')

def Main():

    config, signer = create_signer()
    streamingEnv()
    readMessages(streamingID)

Main()