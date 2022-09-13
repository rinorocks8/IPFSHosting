wget https://dist.ipfs.tech/kubo/v0.15.0/kubo_v0.15.0_linux-amd64.tar.gz
tar xvfz kubo_v0.15.0_linux-amd64.tar.gz
rm kubo_v0.15.0_linux-amd64.tar.gz
sudo ./kubo/install.sh
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