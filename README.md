# abapgit-test

abapGit + GitHub + SAP bağlantısını denemek için örnek repo.

| Dosya | SAP objesi |
|---|---|
| `.abapgit.xml` | Repo ayarları (ana dil TR, `/src/` klasörü, PREFIX klasör mantığı) |
| `src/package.devc.xml` | Paket (SAP'de repo oluştururken seçilen paket, ör. `$ZGIT_TEST`) |
| `src/zgit_test_01.prog.abap` | `ZGIT_TEST_01` programının kaynak kodu |
| `src/zgit_test_01.prog.xml` | Program özellikleri + metinler (text symbol, seçim metni, başlık) |

## SAP'ye alma — Offline (internet gerekmez)
1. SE38 → `ZABAPGIT` çalıştır.
2. **New Offline** → Name: `ZGIT_TEST`, Package: `$ZGIT_TEST` (local paket, transport istemez; yoksa abapGit oluşturmayı teklif eder).
3. **Import zip** → `abapgit-test.zip` seç.
4. **Pull** → objeleri onayla → Activate.
5. SE38 → `ZGIT_TEST_01` → F8.

## SAP'ye alma — Online (GitHub)
1. GitHub'da boş bir repo aç, bu klasörü push et.
2. `ZABAPGIT` → **New Online** → URL: `https://github.com/<kullanici>/abapgit-test.git`, Package: `$ZGIT_TEST`.
3. Private repo ise kullanıcı adı + Personal Access Token istenir.
4. **Pull** → Activate.

Online için SAP sunucusunun github.com'a erişebilmesi ve STRUST'ta (SSL client Anonymous/Standard)
GitHub sertifikalarının yüklü olması gerekir.

## Test döngüsü
Kodu burada değiştir → commit + push → SAP'de **Pull** → değişiklik SAP'de.
SAP'de değiştir → abapGit **Stage** → commit → GitHub'a gider.
