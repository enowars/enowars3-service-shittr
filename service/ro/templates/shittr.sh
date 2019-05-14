cat <<EOF
<!doctype html>
<html lang="en">

$(render header.sh)

  <body>

$(render navigation.sh)

    <main role="main" class="container">

      <div class="starter-template">
        $(render messages.sh)
        <h1>${TITLE}</h1>
        <h2>$bio</h2>
        <p>$(if [ $if -eq 0 ]; then echo "<a href='/@${OUSER}/follow'>Follow</a>"; else  echo "<a href='/@${OUSER}/unfollow'>Unfollow</a>"; fi) (Follows <a href='/@${OUSER}/following'>$followCnt</a> Shittrs / <a href='/@${OUSER}/followers'>$followerCnt</a> Shitters following)</p>
        <h2>Shits</h2>
        <ul>
EOF
        for s in "${SHITS[@]}"
        do 
          echo "<p>${s}</p>"
        done
cat <<EOF
        </ul>
      </div>

    </main><!-- /.container -->

$(render footer.sh)
  </body>
</html>
EOF