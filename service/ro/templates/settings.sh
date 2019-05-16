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
        <form method="POST">
            <label for='public'>Public profile?</label><input type='checkbox' name='public' $( [ "on" = "$isp" ] && echo -n "checked='checked'")>
            <br>
            <label for="bio">Biography</label><textarea name='bio'>${bio}</textarea>
            <br>
            <input type='submit' name='submit'>
        </form>
        <form method="POST" action='/download'>
            <p>DSGVO sucks, but we don't give a shit about your data anyway..</p>
            <input type='submit' value='Download shits!' name='downloadshits'>
        </form>
      </div>

    </main><!-- /.container -->

$(render footer.sh)
  </body>
</html>
EOF