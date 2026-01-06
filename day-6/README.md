# Day 6 - Volumes k8s

- [doc kubernetes](https://kubernetes.io/docs/concepts/storage/storage-classes)
- [aula](https://github.com/badtuxx/CertifiedContainersExpert/tree/main/DescomplicandoKubernetes/day-6)

## Comandos importantes da aula:
### NFS

Criar diretório nfs no mnt:
```
mkdir /mnt/nfs
```

Instala pacotes de nfs
```
sudo apt-get install nfs-kernel-server nfs-common
```

Edita arquivo exports para colocar o diretório na montagem: `/etc/exports`
```
/mnt/nfs *(rw,sync,no_root_squash,no_subtree_check)
```

Restart na árvore de diretórios:
```
sudo exportfs -arv
```

Verifica diretório: `showmount -e 192.168.0.106`

Resposta:
```
Export list for 192.168.0.106:
/mnt/nfs *
```