#!/bin/bash
prompt_password() {
  while true; do
    read -p "パスワード管理ファイルのパスワードを入力してください: " password1
    read -p "もう一度パスワードを入力してください: " password2
    if [ -n "$password1" ] && [ "$password1" == "$password2" ]; then
      echo "$password1"
      break
    else
      echo  -e "\nパスワードが一致しません。もう一度実行してください。\n" >&2
    fi
  done
}

add_password() {
  if [ -f "$encrypted_password_file" ]; then
    gpg --decrypt --batch --yes --passphrase "$GPG_PASS" --quiet --output "$password_file" "$encrypted_password_file"
    check_gpg_status
  fi

  echo # スペースを入れるためにechoを入れています。
  prompt_input "サービス名を入力してください：" service_name
  prompt_input "ユーザー名を入力してください：" user_name
  prompt_input "パスワードを入力してください：" password
  
  echo "$service_name:$user_name:$password" >> "$password_file"
  gpg --symmetric --cipher-algo aes256 --batch --yes --passphrase "$GPG_PASS" --output "$encrypted_password_file" "$password_file"
  
  if [ $? -eq 0 ]; then
    echo -e "\nパスワードの追加は成功しました。"
    cleanup_file
  else
    echo -e "\n暗号化に失敗しました。"
    cleanup_file
  fi
}

get_password() {
  if [ -f "$encrypted_password_file" ]; then
    gpg --decrypt --batch --yes --passphrase "$GPG_PASS" --quiet --output "$password_file" "$encrypted_password_file"
    check_gpg_status
  else  
    touch "$password_file"
  fi
  
  echo # スペースを入れるためにechoを入れています。
  read -p "サービス名を入力してください：" service_name
  search_results=$(awk -F":" -v service="$service_name" '$1 == service' "$password_file")
  if [ -n "$search_results" ]; then
    while IFS=$":" read service user pass; do
      echo "サービス名：" $service
      echo "ユーザー名：" $user
      echo "パスワード：" $pass
      echo # スペースを入れるためにechoを入れています。
    done <<< "$search_results"
  else
    echo -e "\nそのサービスは登録されていません。"
  fi
  
  cleanup_file
}

prompt_input() {
  local prompt="$1"
  local var_name="$2"

  while true; do
    read -p "$prompt" input_value
    if [ -n "$input_value" ]; then
      eval "$var_name=\$input_value" # prompt_inputの第二引数にinput_valueの値を格納したいため、evalを使用して変数が展開しコマンド実行する。
      break
    else
      echo "入力を確認できませんでしたので、再度入力してください。"
    fi
  done
}

check_gpg_status() {
  if [ $? -ne 0 ]; then
    echo "暗号化ファイルを復号化できませんでした。"
    exit 1
  fi
}

cleanup_file() {
  if [ -f "$password_file" ]; then
    rm "$password_file"
  fi
}

echo "パスワードマネージャーへようこそ！"

password_file="password.txt"
encrypted_password_file="${password_file}.gpg"
env_file=".env"

if [ ! -f "$env_file" ]; then
  echo "GPG_PASS=\"$(prompt_password)\"" > "$env_file"
fi

gpg_pass_value=$(awk -F "=" '/^GPG_PASS=/ {print $2}' "$env_file")

if [ ! -n "$gpg_pass_value" ]; then
  sed -i "s/^GPG_PASS=.*/GPG_PASS=\"$(prompt_password)\"/" "$env_file"
fi

export $(cat .env | grep -v ^# | sed 's/"//g')

while true; do
  read -p "次の選択肢から入力してください(Add Password/Get Password/Exit)：" select_option
  
  case "$select_option" in
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
