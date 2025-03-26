
# **Penjelasan Lengkap Proyek Flutter "manlogen"**

Proyek Flutter yang kamu buat bernama **manlogen**, yang bertujuan untuk membuat aplikasi mobile dengan fitur dasar berupa **Login** dan **Registrasi** pengguna. Selain itu, proyek ini sudah dipersiapkan dengan baik secara modular, sehingga kode lebih rapi, mudah dikelola, dan siap untuk dikembangkan lebih lanjut, seperti integrasi dengan backend untuk autentikasi pengguna dan visualisasi data dari sensor IoT.

::: mermaid
flowchart TD
    A[Proyek Manlogen] --> B[assets]
    A --> C[lib]
    
    B --> B1[images]
    B1 --> B1a[widya_matador_logo.jpeg]
    
    C --> C1[screens]
    C --> C2[components]
    C --> C3[constants]
    C --> C4[main.dart]
    
    C1 --> C1a[welcome.dart]
    C1 --> C1b[login.dart]
    C1 --> C1c[signup.dart]
    
    C2 --> C2a[rounded_button.dart]
    C2 --> C2b[input_field.dart]
    
    C3 --> C3a[colors.dart]
    
    D[pubspec.yaml] --> D1[dependencies]
    D1 --> D1a[cupertino_icons]
    D1 --> D1b[flutter_svg]
    
    %% Flow aplikasi
    subgraph AppFlow[Alur Navigasi Aplikasi]
        F1[WelcomeScreen] -->|Login Button| F2[LoginScreen]
        F1 -->|Sign Up Button| F3[SignUpScreen]
    end
    
    %% Komponen reusable
    subgraph Components[Komponen Reusable]
        G1[RoundedButton] --- C2a
        G2[InputField] --- C2b
    end
    
    %% Main execution
    subgraph MainExecution[Eksekusi Utama]
        H1[main.dart] -->|Run| H2[MyApp]
        H2 -->|home:| F1
    end
    
    %% Future Integration
    subgraph FutureIntegration[Integrasi Masa Depan]
        I1[Flutter Frontend] -->|HTTP Request| I2[Backend API]
        I2 -->|Query| I3[PostgreSQL in Docker]
        I2 -->|Response| I1
    end
:::

## **Struktur Folder Proyek**

Proyek ini terdiri dari beberapa folder utama:

1. **Folder assets**  
Folder ini khusus digunakan untuk menyimpan semua aset seperti gambar, icon, logo, atau aset visual lainnya yang akan digunakan dalam aplikasi. Di dalamnya terdapat subfolder `images` yang berisi gambar logo aplikasi, yaitu file `widya_matador_logo.jpeg`. Gambar ini akan ditampilkan di halaman Welcome dan Login.

2. **Folder lib**  
Folder inti dalam proyek Flutter yang menyimpan semua kode Dart. Di dalamnya ada folder tambahan seperti:
   - **screens**: berisi halaman aplikasi (`welcome.dart`, `login.dart`, dan `signup.dart`).
   - **components**: berisi widget yang bersifat reusable seperti tombol (`rounded_button.dart`) dan input text (`input_field.dart`).
   - **constants**: menyimpan nilai-nilai konstan yang digunakan secara global dalam aplikasi (`colors.dart`).

---

## **Penjelasan File `pubspec.yaml`**

File ini berfungsi untuk mengatur dependensi eksternal dan juga aset yang digunakan dalam aplikasi. Dalam file ini, kamu telah menambahkan beberapa dependensi penting seperti:

- **cupertino_icons**, yang menyediakan icon untuk tampilan aplikasi, khususnya tampilan gaya iOS.
- **flutter_svg**, berguna untuk menampilkan gambar vektor berformat SVG di dalam aplikasi.

Selain dependensi, file ini juga mengatur penggunaan asset berupa gambar. Pada bagian ini, Flutter akan diberitahu bahwa folder `assets/images` berisi gambar yang siap digunakan dalam aplikasi.

---

## **Penjelasan File `main.dart`**

File `main.dart` merupakan entry point atau gerbang utama aplikasi Flutter. Di sinilah aplikasi dimulai. File ini memiliki satu fungsi utama yaitu `main()`. Fungsi `main()` tersebut menjalankan widget utama aplikasi bernama `MyApp`.

Kelas `MyApp` sendiri mengembalikan widget bernama `MaterialApp` yang merupakan dasar untuk membuat aplikasi dengan desain Material yang khas dari Google. Dalam `MaterialApp`, kamu menentukan beberapa hal penting seperti:

- `title`: Judul aplikasi yaitu `"Login App"`.
- `theme`: Tema warna aplikasi (`Colors.blue` sebagai warna utama).
- `home`: Halaman pertama yang akan muncul ketika aplikasi dijalankan yaitu halaman Welcome (`WelcomeScreen()`).
- `debugShowCheckedModeBanner`: opsi untuk menampilkan atau menghilangkan banner debug, di sini diatur ke `false` agar tampilannya lebih bersih.

---

## **Penjelasan File Halaman (`screens/`)**

Dalam folder ini, ada tiga halaman utama aplikasi, yaitu:

### **a. `welcome.dart`**
Halaman ini menampilkan logo aplikasi (`widya_matador_logo.jpeg`) menggunakan widget `Image.asset`. Di bawah logo terdapat dua tombol utama yang navigasinya telah disiapkan menggunakan widget `ElevatedButton`:

- Tombol **Login**, yang mengarahkan pengguna ke halaman Login.
- Tombol **Sign Up**, yang mengarahkan pengguna ke halaman registrasi.

Halaman Welcome adalah titik awal navigasi pengguna di aplikasi kamu.

### **b. `login.dart`**
Halaman ini digunakan untuk memasukkan data login pengguna. Tampilan login memiliki:

- Logo aplikasi untuk branding.
- Dua input field, yaitu email dan password, masing-masing menggunakan widget custom yang telah dibuat, yakni `InputField`. Input ini menangkap data yang dimasukkan pengguna.
- Tombol login yang menggunakan widget `RoundedButton`. Saat ini tombol login hanya mencetak data di console untuk pengujian, namun nantinya akan terhubung ke backend API untuk autentikasi pengguna.

### **c. `signup.dart`**
Halaman ini secara struktur mirip dengan halaman login, namun tujuannya untuk registrasi pengguna baru. Nanti akan berisi input seperti email, password, dan informasi tambahan sesuai kebutuhan aplikasi.

---

## **Penjelasan Folder `components` (Widget Reusable)**

Dalam folder ini terdapat dua komponen penting yang sering digunakan berulang-ulang di berbagai halaman aplikasi:

### **a. `rounded_button.dart`**
Widget ini adalah tombol dengan desain custom berbentuk bulat. Tombol ini dibuat menggunakan widget dasar Flutter bernama `ElevatedButton`. Tombol ini menerima beberapa parameter:

- **text** (teks tombol),
- **press** (fungsi yang dijalankan ketika tombol ditekan),
- **color** (warna tombol),
- **textColor** (warna teks).

Keuntungan menggunakan komponen ini adalah untuk menjaga konsistensi desain dan memudahkan modifikasi desain tombol di seluruh aplikasi hanya melalui satu file saja.

### **b. `input_field.dart`**
Komponen ini dibuat untuk input teks seperti email atau password yang digunakan berulang-ulang. Dibangun menggunakan widget dasar Flutter bernama `TextField`. Komponen ini menerima parameter seperti:

- **hintText** (teks petunjuk di dalam field),
- **icon** (ikon di sebelah kiri input),
- **obscureText** (untuk input password),
- **onChanged** (fungsi untuk menangkap nilai yang dimasukkan pengguna).

Keuntungan memakai widget reusable ini adalah mengurangi pengulangan kode dan menyeragamkan desain input di seluruh halaman aplikasi kamu.

---

## **Penjelasan Folder `constants` (Nilai Konstan)**

Folder ini berisi file `colors.dart`, yang mendefinisikan nilai-nilai warna utama yang digunakan aplikasi secara global. Ini bertujuan agar warna dalam aplikasi tetap konsisten dan mudah diatur jika diperlukan perubahan warna utama nantinya.

Warna utama yang digunakan adalah:

- **kPrimaryColor**: warna utama untuk elemen-elemen utama seperti tombol, teks yang menonjol, atau ikon utama.
- **kPrimaryLightColor**: warna utama versi terang, biasanya digunakan untuk background atau elemen-elemen yang tidak dominan.

---

## **Cara Kerja Halaman Login dan Registrasi (Nantinya)**

Saat ini, halaman login dan registrasi belum terhubung ke backend. Namun secara umum, nanti akan berjalan seperti ini:

- Pengguna memasukkan email dan password di halaman login atau registrasi.
- Setelah pengguna menekan tombol login atau sign up, Flutter akan mengirimkan data tersebut melalui request HTTP ke backend API yang akan kamu buat (menggunakan FastAPI atau Express.js, misalnya).
- Backend akan menerima data, memvalidasi dengan database (PostgreSQL dalam Docker), kemudian mengirimkan kembali respon berupa autentikasi sukses atau gagal.
- Jika autentikasi sukses, pengguna akan diarahkan ke halaman utama aplikasi yang menampilkan data sensor dalam bentuk grafik atau chart.

---

## **Kesimpulan dan Langkah Berikutnya**

Proyek Flutter ini sudah memiliki dasar UI yang baik, struktur modular yang rapi, dan telah siap untuk diintegrasikan dengan backend untuk autentikasi pengguna dan visualisasi data sensor. Langkah berikutnya yang perlu kamu lakukan adalah:

1. Membuat backend dengan REST API untuk autentikasi.
2. Menjalankan database PostgreSQL menggunakan Docker.
3. Menghubungkan frontend aplikasi Flutter ini dengan backend tersebut.
4. Mengembangkan fitur visualisasi data sensor setelah login berhasil.

Dengan memahami secara mendalam struktur, file, dan kode dalam proyek ini, kamu sudah siap untuk langkah integrasi berikutnya.

---
