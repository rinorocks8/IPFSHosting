wget https://dist.ipfs.tech/kubo/v0.16.0/kubo_v0.16.0_linux-arm64.tar.gz
tar xvfz kubo_v0.16.0_linux-arm64.tar.gz
rm kubo_v0.16.0_linux-arm64.tar.gz
sudo ./kubo/install.sh
mkdir /home/ubuntu/files
sudo chmod 777 /home/ubuntu/files
mkdir /home/ubuntu/ipfs
mkdir /home/ubuntu/ipfs/data
echo 'export IPFS_PATH=/home/ubuntu/ipfs/data' >> ~/.profile
source ~/.profile
ipfs init --profile server
ipfs config Datastore.StorageMax 2GB
ipfs config Addresses.Gateway /ip4/0.0.0.0/tcp/8080
sudo systemctl daemon-reload
sudo systemctl enable ipfs.service
sudo systemctl start ipfs

sudo apt install unzip
rm -r ./aws/
curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
unzip -u awscliv2.zip
sudo ./aws/install --update
rm awscliv2.zip
rm -r ./aws/