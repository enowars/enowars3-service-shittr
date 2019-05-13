cat <<EOF
<!doctype html>
<html lang="en">

$(render header.sh)

  <body>

$(render navigation.sh)

    <main role="main" class="container">

      <div class="starter-template">
        <h1>${TITLE}</h1>
        <form method="POST">
            <label for='public'>Public profile?</label><input type='checkbox' name='public' $( [ "on" = "$isp" ] && echo -n "checked='checked'")>
            <br>
            <label for="bio">Biography</label><textarea name='bio'>${bio}</textarea>
            <br>
            <input type='submit' name='submit'>
        </form>
      </div>

    </main><!-- /.container -->

$(render footer.sh)
  </body>
</html>
EOF