#!/bin/bash
list=`ls /etc/terraform-stacks/`
terraformbuild=/etc/terraform-stacks
echo "<p><b>Production/Stage/Test/Dev</b>.</p>" > /tmp/temp.log
stacklog=/tmp/temp.log

for stack in $list
do
echo "===================="
cd /$terraformbuild/$stack
terraform plan >/dev/null

if [ $? -eq 0 ]
then
  status1=`terraform plan | grep "No changes" | awk 'BEGIN { FS = " " } ; { print $1 $2 }'`
        if
                [ "$status1" == "Nochanges." ]
        then
                echo "<p>$stack ......Built and needs no changes.</p>" >>$stacklog

                elif
                        status3=`terraform plan | grep "Plan" | awk 'BEGIN { FS = " " } ; { print $2 }'`
                        [ "$status3" -gt 0 ]
                then
                        echo "<p>$stack ......<em>Pending build.</em></p>" >>$stacklog
        else
                if
                        status2=`terraform plan | grep "to change" | awk 'BEGIN { FS = " " } ; { print $6 $7 }'`
                        [ "$status2" == "tochange," ]
                then
                        echo "<p>$stack ......Built with <mark>changes pending</mark>.</p>" >>$stacklog
                else
                        echo "<p>$stack .......Not Built.</p>" >>$stacklog
                fi

        fi
else
  echo "<p>$stack .......Error in Config.</p>" >>$stacklog
fi

done

mailtext=`cat $stacklog`
aws ses send-email --from "email" --to "Email1" "Email2" --subject "Terraform Stack Status" --html "$mailtext"
