# SISOP-1-2026-IT-047
Nama    : Putri Permata Sabila <br>
NRP     : 5027251047 <br>
Kelas   : A <br>

## Laporan Resmi

### Soal 1

Pada soal 1 kita diberikan data penumpang di kereta dan diminta untuk menampilkan <br>
a. Jumlah seluruh penumpang <br>
b. Jumlah gerbong penumpang <br>
c. Penumpang tertua <br>
d. Rata-rata usia penumpang <br>
e. Jumlah penumpang *bussiness class*

Langkah pertama sebelum kita menampilkan data. kita harus mendowload passenger.csv dari spreadsheet masuk ke repository menggunakan `wget -O`

```sh
wget -O passenger.csv "https://docs.google.com/spreadsheets/d/1NHmyS6wRO7To7ta-NLOOLHkPS6valvNaX7tawsv1zfE/export?format=csv"
```

#### A) Menghitung jumlah penumpang yang ada di kereta
```sh
BEGIN {FS=","}NR>1 {count++}
END {print "Jumlah seluruh penumpang KANJ adalah ", count, " orang"}
```
#### B) Menghitung jumlah gerbong yang ada dalam kereta dengan menghitung *length* dari array kolom ke-4 
```sh
BEGIN {FS=","} NR>1 {carriage[$4]++}
END {print"Jumlah gerbong penumpang KANJ adalah",length(carriage)}
```
#### C) Mencari penumpang tertua dalam kereta dengan melakukan perbandingan di kolom ke-2 yang menyimpan umur, lalu ketika sudah selesai menyimpan nama penumpang tertua di `max_name`
```sh
BEGIN{FS=","}NR>1{if($2>max) {max =$2;max_name=$1}}END {print max_name, "adalah penumpang kereta tertua dengan usia", max,"tahun"} 
```
#### D) Menghitung rata-rata usia penumpang dengan menjumlahkan total umur di kolom ke-2 lalu membagi jumlah orang yang ada
```sh
BEGIN {FS=","} NR>1 { total+=$2; count_person++ }
END {print "Rata-rata usia penumpang adalah",total/count_person, "tahun" }
```
#### E) Menhitung jumlah penumpang yang ada di bussiness class. Jika pada kolom ke-3 ditemukan "Businees" maka `count_business++`
```sh
BEGIN {FS=","} NR>1 {if ($3=="Business"){count_business++}}
END {print "Jumlah penumpang business class ada", count_business}
```
karena *command* yang digunakan untuk memunculkan *output*

```sh
awk -f KANJ.sh passenger.csv a/b/c/d/e 
```
maka berikut ini full code penggabungannya 

```sh
BEGIN {FS=",";choice = ARGV[2];delete ARGV[2]
if (choice != "a" && choice != "b"&& choice != "c" && choice != "d" && choice != "e"){
print"Soal tidak dikenali. Gunakan a,b,c,d atau e."; 
print"Contoh penggunaan: awk -f file.sh data.csv a"}
}

NR > 1 {
if (choice =="a") count++
if (choice =="b") carriage[$4]++
if (choice =="c") {if($2>max) {max =$2;max_name=$1}}
if (choice =="d") { total+=$2; count_person++ }
if (choice =="e") if ($3 =="Business")count_business++
}

END {
if (choice =="a") 
{print "Jumlah seluruh penumpang KANJ adalah ", count, " orang"}
if (choice=="b")
{print"Jumlah gerbong penumpang KANJ adalah",length(carriage)}
if (choice=="c")
{print max_name, "adalah penumpang kereta tertua dengan usia",max,"tahun"}
if (choice =="d")
{print "Rata-rata usia penumpang adalah", total/count_person, "tahun"}
if (choice=="e")
{print "Jumlah penumpang business class ada", count_business, "orang"}
} 
```
`ARGV` merupakan array yang menyimpan semua argumen di command line
- `ARGV[0]` = awk
- `ARGV[1]` = passenger.csv
- `ARGV[2]` = a/b/c/e

#### Output
<img width="954" height="491" alt="Screenshot 2026-03-25 181037" src="https://github.com/user-attachments/assets/1a8e8f02-359f-4bf5-a9ab-ad50a690a385" />

### Soal 2

