cat <<EOF
<!doctype html>
<html lang="en">

$(render header.sh)

  <body>

$(render navigation.sh)

    <main role="main" class="container">

      <div class="starter-template">
        <h1>${TITLE}</h1>
        <h2>$bio</h2>
        <h3>$(if [ $if -eq 0 ]; then echo "<a href='/follow/@${OUSER}'>Follow</a>"; else  echo "<a href='/unfollow/@${OUSER}'>Unfollow</a>"; fi) (Follows $followCnt Shittrs / $followerCnt Shitters following)</h3>
        <ul>
        </ul>
      </div>

    </main><!-- /.container -->

$(render footer.sh)
  </body>
</html>
EOF