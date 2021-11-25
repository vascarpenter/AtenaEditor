# AtenaEditor

- なぜ作ったか
  - 宛名職人が V28にアップグレード失敗
    - ソースネクストに金だけとられてシリアルもダウンロードすらできない状態だったため八つ当たりで作った
    - 返金してもらった
    - 原因は、V26アップグレード時からさらにアップグレード版を値上げしたせいと思われる

- 宛名職人CSVを sqliteに変換し編集するプログラム
  - ViewControllerにすべて任せるクソ構造
  - 住所や名前のいわゆるエントリの作成、編集、削除、更新(CRUD)は、CSVの段階でやってください。このプログラムにはそんな機能はない。
  - CSVの形式(utf8,lf) は同梱の `dummy_list.csv` をみてね

- 宛名職人CSVの作成方法
  - 宛名職人のメニューから UTF-8/LF の ContactXML 形式で書き出す
  - `./atenaCXMLconv ~/Desktop/jushoContact.xml >~/jusho.csv`
  - Fileメニューから Open CSV... を選び、その CSV ファイルを選ぶと、内部databaseに読み込む
  - CSVの形式(utf8,lf) は同梱の `dummy_list.csv` をみてね 
  
- 選択
  - Selectionメニューに去年喪中かはがきもらった人を選択できるようになっている
  - その選択の後に選択マークをつける
  - 選択マークのみ表示し、それを CSV に書き出せます
  
- 今年はカメラのキタムラがデザインがいいということで、そのフォーマットで書き出すことになりましたパチパチパチ
  - SJISしか使えないとか時代遅れ〜
  - いまどきCRLFとか時代遅れ〜
  - 書き出せるのはいまんとこキタムラ形式：ヘッダ＋データだけ
  - いまどき自宅で宛名印刷とかするわけないじゃん？

- 以下たわごと
  - いまどき ViewControllerに糞ほど詰め込むとか汚すぎ〜
  - 動けばいいのだよ..
- GRDB.swift を github から Swift Packageとして追加
  - Xcode> File> Add Packages.. > github を選ぶ
  - URL https://github.com/groue/GRDB.swift を入れる
  - 左リストしたに Package Dependencies: GRDB masterと出る
  - 同様に SwiftCSV packageも追加
- mac App Sandboxを解除しないと 当然ながら DBへの書き込みはできないよ
- CSVからSQLiteへの変換 (CSV読み込みを作成したので不要)
  - TablePlusの Import CSV Wizardを使う
  - atxBaseYear を int それ以外を varchar として読み込みをする
  - 最後の列は空列なので do not import
  - 表を自動作成し、2行目以降をデータとして取り込んでくれる
  - Rename SQLite struct name
    - swift struct name に X-　は使わないので変更
    - `ALTER TABLE "AddrList" RENAME COLUMN "X-Suffix1" TO "Suffix1";`
    - `ALTER TABLE "AddrList" RENAME COLUMN "X-Suffix2" TO "Suffix2";`
    - `ALTER TABLE "AddrList" RENAME COLUMN "X-Suffix3" TO "Suffix3";`
    - `ALTER TABLE "AddrList" RENAME COLUMN "X-NYCardHistory" TO "NYCardHistory";`

  - rownum が SQLiteの場合ないので、idフィールドを追加
  - 順番に idフィールドを追加していくのは perlを使った
    ```
    use DBI;

    $database = "./Atena.sqlite";
    $dbi = DBI->connect("dbi:SQLite:dbname=$database");
    $statement = $dbi->prepare('SELECT * FROM AddrList');
    $statement->execute();

    $i = 0;
    while ($row = $statement->fetch())
    {
        $i++;

        print ($row->[0] . "\n");
        $u = "update AddrList set id=? where LastName=? AND FirstName=?";
        $s2 = $dbi->prepare($u);
        $s2->execute( ($i, $row->[0], $row->[1]) );

    }
    $dbi->disconnect;
    ```

