#!/bin/bash
echo "パスワードマネージャーへようこそ！"

get_input() {
  local prompt="$1"
  local var_name="$2"

  while true; do
    read -p "$prompt" input_value
    if [ -n "$input_value" ]; then
      eval "$var_name=\$input_value"
      break
    else
      echo "入力を確認できませんでしたので、再度入力してください"
    fi
  done
}

get_input "サービス名を入力してください：" service_name
get_input "ユーザー名を入力してください：" user_name
get_input "パスワードを入力してください：" password

file="password.txt"
echo "$service_name:$user_name:$password" >> "$file"

if [ $? -eq 0 ]; then
  echo -e "\nThank you!"
else
  echo "ファイルの保存に失敗しました。"
fi
