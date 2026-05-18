#!/bin/bash

# ==============================
# Auto Backup Script
# Project: automation_project
# ==============================

PROJECT_DIR="$HOME/automation_project"
DATA_DIR="$PROJECT_DIR/data"
BACKUP_DIR="$PROJECT_DIR/backups"
LOG_DIR="$PROJECT_DIR/logs"
LOG_FILE="$LOG_DIR/backup.log"

TIME_NOW=$(date +"%Y-%m-%d %H:%M:%S")
BACKUP_TIME=$(date +"%Y-%m-%d_%H-%M")
BACKUP_NAME="data_backup_${BACKUP_TIME}.tar.gz"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"

# Tao thu muc logs neu chua ton tai
mkdir -p "$LOG_DIR"

echo "======================================" >> "$LOG_FILE"
echo "Thoi gian chay script: $TIME_NOW" >> "$LOG_FILE"

# Yeu cau 1: Kiem tra thu muc backups
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    echo "Thu muc backups chua ton tai. Da tao moi."
    echo "Thu muc backups chua ton tai. Da tao moi." >> "$LOG_FILE"
else
    echo "Thu muc backups da ton tai."
    echo "Thu muc backups da ton tai." >> "$LOG_FILE"
fi

# Kiem tra thu muc data
if [ ! -d "$DATA_DIR" ]; then
    echo "Loi: Thu muc data khong ton tai."
    echo "Trang thai backup: That bai - Thu muc data khong ton tai." >> "$LOG_FILE"
    exit 1
fi

# Yeu cau 4: Kiem tra ket noi Internet
ping -c 1 -W 2 google.com.vn > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "Co ket noi Internet."
    echo "Ket noi Internet: Co ket noi" >> "$LOG_FILE"
else
    echo "Khong co ket noi Internet."
    echo "Ket noi Internet: Khong co ket noi" >> "$LOG_FILE"
fi

# Yeu cau 2: Nen thu muc data thanh file backup
tar -czf "$BACKUP_PATH" -C "$PROJECT_DIR" data

# Yeu cau 3: Ghi log trang thai backup
if [ $? -eq 0 ]; then
    echo "Backup thanh cong: $BACKUP_NAME"
    echo "Ten file backup: $BACKUP_NAME" >> "$LOG_FILE"
    echo "Trang thai backup: Thanh cong" >> "$LOG_FILE"
else
    echo "Backup that bai."
    echo "Ten file backup: $BACKUP_NAME" >> "$LOG_FILE"
    echo "Trang thai backup: That bai" >> "$LOG_FILE"
    exit 1
fi

# BONUS 1: Chi giu lai 5 file backup moi nhat
OLD_BACKUPS=$(ls -1t "$BACKUP_DIR"/data_backup_*.tar.gz 2>/dev/null | tail -n +6)

if [ -n "$OLD_BACKUPS" ]; then
    echo "$OLD_BACKUPS" | xargs rm -f
    echo "Da xoa cac backup cu, chi giu lai 5 file moi nhat." >> "$LOG_FILE"
else
    echo "Khong co backup cu can xoa." >> "$LOG_FILE"
fi

# BONUS 2: Tu dong commit va push len GitHub neu project da cau hinh Git
cd "$PROJECT_DIR"

if [ -d ".git" ]; then
    git add .

    if git diff --cached --quiet; then
        echo "Git: Khong co thay doi moi de commit." >> "$LOG_FILE"
    else
        git commit -m "Auto backup $BACKUP_TIME"

        if git remote get-url origin > /dev/null 2>&1; then
            git push origin main
            echo "Git: Da commit va push len GitHub." >> "$LOG_FILE"
        else
            echo "Git: Chua cau hinh remote origin." >> "$LOG_FILE"
        fi
    fi
else
    echo "Git: Project chua duoc khoi tao Git repository." >> "$LOG_FILE"
fi

# BONUS 3: Thong bao hoan thanh
echo "Hoan thanh qua trinh backup."
echo "Thong bao: Hoan thanh qua trinh backup." >> "$LOG_FILE"
