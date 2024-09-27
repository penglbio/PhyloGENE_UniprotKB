#!/bin/bash

# 定义一个数组，包含所有tSV文件的名称
# 假设 $@ 包含了所有的参数
# 将所有参数复制到一个新的数组
args=("$@")

# 计算参数的数量
num_args=${#args[@]}

# 如果参数数量大于1，则去掉最后一个参数
if [ "$num_args" -gt 1 ]; then
  # 使用数组切片去掉最后一个元素
  tsv_files=("${args[@]:0:$((num_args - 1))}")
  output_file="${args[-1]}"
else
  # 如果没有参数或只有一个参数，那么 new_args 就是空数组
  tsv_files=()
  exit 1
fi

# 打印新的数组
echo "New array without the last element: ${tsv_files[@]}"



# 检查文件数量是否大于1，因为至少需要两个文件才能进行合并
if [ ${#tsv_files[@]} -lt 1 ]; then
    echo "需要至少两个CSV文件来合并。"
    exit 1
fi

# 临时存储合并结果的文件
temp_file1="temp_merged1_5k.csv"
temp_file2="temp_merged2_5k.csv"

# 合并前两个文件作为初始结果
csvtk join -tHl -f "1,2,4;1,2,3" -k --na NA "${tsv_files[0]}" "${tsv_files[1]}" > "$temp_file1"

# 从第二个文件开始，逐个与临时文件合并
for (( i=2; i<${#tsv_files[@]}; i++ )); do
    csvtk join -tHl -f "1,2,4;1,2,3" -k --na NA "$temp_file1" "${tsv_files[$i]}" > "$temp_file2"
    mv $temp_file2 $temp_file1
done

# 从文件名中生成表头
# 假设每个文件名代表一个不同的列
header=""
for file in "${tsv_files[@]:1:$num_args}"; do
    # 去掉_clean.tsv扩展名，并将结果添加到表头字符串
    header+=$(basename "$file" _clean.tsv)$'\t'
done

# 去除表头字符串最后的制表符
header=${header%$'\t'}
mkdir -p "$(dirname "$output_file")"
#输出header到merge文件
echo -e "taxid\tgene_nums\ttaxid\tlineage\t$header" > $output_file
# 最后，将临时文件重命名为最终输出文件
cat "$temp_file1" >> $output_file 
rm "$temp_file1"
