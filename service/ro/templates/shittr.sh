cat <<EOF
<!doctype html>
<html lang="en">

$(render header.sh)

  <body>

$(render navigation.sh)

    <main role="main" class="container">

      <div class="">
        $(render messages.sh)
        
        <div class="row">
          <div class="col-lg-3">
              <h1>@${OUSER}</h1>
              <h5>$(htmlEscape "$bio")</h5>
              <div class="table-responsive">
                <table class="table table-dark table-striped table-hover">
                  <tr>
                    <td style="text-align: center">$(if [ $if -eq 0 ]; then echo "<a href='/@${OUSER}/follow'>Follow</a>"; else  echo "<a href='/@${OUSER}/unfollow'>Unfollow</a>"; fi)</td>
                  </tr>
                  <tr>
                   <td><a href='/@${OUSER}/following'>$followCnt</a> Following</td>
                  </tr>
                  <tr>
                    <td><a href='/@${OUSER}/followers'>$followerCnt</a> Followers</td>
                  </tr>
                </table>
              </div>
          </div>
          <div class="col-lg-9">
            <h1>Shits</h1>
            <table class="table table-hover table-striped table-dark">
            <tbody>
EOF
        for s in "${SHITS[@]}"
        do 
          cat <<EOF
                <tr>
                  <td>${s}</td>
                </tr>
EOF
        done
cat <<EOF
          </tbody>
          </table>
        </div>
      </div>
    </div>

    </main><!-- /.container -->

$(render footer.sh)
  </body>
</html>
EOF