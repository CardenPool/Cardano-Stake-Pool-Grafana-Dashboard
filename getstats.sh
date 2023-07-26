curl https://js.cexplorer.io/api-static/pool/pool1e3y7u0rtq2zskc7ansvtrd4p3vtv9hglyztzcvsvlk22w9t40v0.json 2>/dev/null \
| jq '.data' | jq 'del(.stats, .url , .img, .updated, .handles, .pool_id, .name, .pool_id_hash)' \
| tr -d \"{},: \
| awk NF \
| sed -e 's/^[ \t]*/cexplorer_/' > poolStat.prom
