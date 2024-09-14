#!/bin/bash
echo "パスワードマネージャーへようこそ！"

file="password.txt"

add_password() {
  get_input "サービス名を入力してください：" service_name
  get_input "ユーザー名を入力してください：" user_name
  get_input "パスワードを入力してください：" password
  
  echo "$service_name:$user_name:$password" >> "$file"
  
  if [ $? -eq 0 ]; then
    echo -e "\nThank you!"
  else
    echo "ファイルの保存に失敗しました。"
  fi
}

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

get_password() {
  read -p "サービス名を入力してください：" service_name
  searchResults=$(awk -F':' -v service="$service_name" '$1 == service' "$file")
  if [ -z "$searchResults" ]; then
    echo -e "\nそのサービスは登録されていません。"
  else
    while IFS=$':' read service user pass; do
      echo
      echo "サービス名：" $service
      echo "ユーザー名：" $user
      echo "パスワード：" $pass
    done <<< "$searchResults"
  fi
}

while true; do
  read -p "次の選択肢から入力してください(Add Password/Get Password/Exit)：" selectOption
  
  case "$selectOption" in
    "Add Password")
      add_password
      ;;
    
    "Get Password")
      get_password
      ;;
      
    "Exit")
      echo -e "\nThank you!"
      break
      ;;
    
    *)
      echo -e "\n入力が間違えています。Add Password/Get Password/Exit から入力してください。"  
      ;;
      
  esac
done
