cat <<EOF
<!doctype html>
<html lang="en">

$(render header.sh)

  <body>

$(render navigation.sh)

    <main role="main" class="container">

      <div class="starter-template">
        <h1>Tag: ${TAG}</h1>
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