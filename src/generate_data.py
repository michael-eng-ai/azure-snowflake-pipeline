import os
import csv
import uuid
import random
from datetime import datetime
from faker import Faker
from dotenv import load_dotenv
from azure.storage.filedatalake import DataLakeServiceClient

# Carrega variáveis do arquivo .env (caso exista)
load_dotenv()

# Configurações do Azure
CONNECTION_STRING = os.getenv("AZURE_STORAGE_CONNECTION_STRING")
FILE_SYSTEM_NAME = os.getenv("AZURE_FILE_SYSTEM_NAME", "raw-data")

def get_service_client():
    """Tenta conectar ao Azure usando a connection string."""
    if not CONNECTION_STRING:
        print("⚠️ Aviso: AZURE_STORAGE_CONNECTION_STRING não definida. Dados serão gerados apenas localmente.")
        return None
    try:
        service_client = DataLakeServiceClient.from_connection_string(CONNECTION_STRING)
        return service_client
    except Exception as e:
        print(f"❌ Erro ao conectar na Azure: {e}")
        return None

def generate_sales_data(num_records=100):
    """Gera uma lista de dicionários contendo transações falsas de e-commerce."""
    fake = Faker('pt_BR')
    sales = []
    
    products = ['Laptop', 'Smartphone', 'Tablet', 'Monitor', 'Teclado Mecânico', 'Mouse Sem Fio']
    
    for _ in range(num_records):
        quantity = random.randint(1, 5)
        unit_price = round(random.uniform(50.0, 5000.0), 2)
        total_amount = round(quantity * unit_price, 2)
        
        sale = {
            'transaction_id': str(uuid.uuid4()),
            'customer_name': fake.name(),
            'customer_email': fake.email(),
            'product_name': random.choice(products),
            'quantity': quantity,
            'unit_price': unit_price,
            'total_amount': total_amount,
            'transaction_date': fake.date_time_between(start_date='-30d', end_date='now').strftime('%Y-%m-%d %H:%M:%S')
        }
        sales.append(sale)
        
    return sales

def save_and_upload(sales_data, service_client):
    """Salva os dados como um CSV local no /tmp e depois realiza o upload para o ADLS Gen2."""
    timestamp = datetime.now().strftime('%Y%m%d%H%M%S')
    filename = f"sales_dump_{timestamp}.csv"
    local_path = f"/tmp/{filename}"
    
    # Salvar Localmente
    with open(local_path, mode='w', newline='', encoding='utf-8') as file:
        writer = csv.DictWriter(file, fieldnames=sales_data[0].keys())
        writer.writeheader()
        writer.writerows(sales_data)
        
    print(f"✅ Dados salvos localmente em: {local_path}")
    
    # Upload para Azure
    if service_client:
        try:
            print("⏳ Iniciando upload para o Azure Data Lake Gen2...")
            file_system_client = service_client.get_file_system_client(file_system=FILE_SYSTEM_NAME)
            
            # Tenta criar o container/file system caso não exista
            if not file_system_client.exists():
                file_system_client.create_file_system()
                print(f"🆕 Container '{FILE_SYSTEM_NAME}' criado.")
                
            # Define o caminho do arquivo dentro do Storage na pasta 'sales'
            file_client = file_system_client.get_file_client(f"sales/{filename}")
            
            with open(local_path, "rb") as data:
                file_client.upload_data(data, overwrite=True)
                
            print(f"🚀 Sucesso! Arquivo '{filename}' enviado para o Azure ADLS Gen2.")
        except Exception as e:
            print(f"❌ Falha no upload para Azure: {e}")

if __name__ == "__main__":
    print("-" * 50)
    print("🛒 Gerador de Dados de E-commerce (Zero-ETL Source)")
    print("-" * 50)
    data = generate_sales_data(150)
    client = get_service_client()
    save_and_upload(data, client)
    print("-" * 50)
