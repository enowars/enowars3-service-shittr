cat <<EOF
<!doctype html>
<html lang="en">

$(render header.sh)

  <body>

$(render navigation.sh)

    <main role="main" class="container">

      <div class="starter-template">
        <h1>Here are you fellow shittrs, @${USERNAME}!</h1>
        <ul>
EOF
    for s in "${SHITTRS[@]}";
    do
        echo "<li><a href='/@${s}'>@${s}</a></li>";
    done
cat <<EOF
        </ul>
      </div>

    </main><!-- /.container -->

$(render footer.sh)
  </body>
</html>
EOF