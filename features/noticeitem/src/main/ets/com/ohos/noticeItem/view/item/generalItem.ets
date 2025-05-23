/*
 * Copyright (c) 2021-2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Constants, { NotificationItemData, NotificationLayout as Layout} from '../../common/constants';
import basicItem from './basicItem';
import longItem from './longItem';
import multiItem from './multiItem';
import pictureItem from './pictureItem';
import titleItem from './titleItem';
import {Log, CheckEmptyUtils} from '@ohos/common'
import ViewModel from '../../viewmodel/ViewModel';
import ActionComponent from './actionComponent';

const TAG = 'NoticeItem-GeneralItem';

@Component
export default struct GeneralItem {
  @Consume('notificationUpdateSc') updateFlag: number;
  @State hasPicture: boolean = false
  @State @Watch('expandChange') isExpand: boolean = false
  @State needExpand: boolean = true
  @State distributedDeviceName: string = ''
  private itemData: NotificationItemData | undefined = undefined
  private clickAction: () => void = () => {
  };
  private isSubItem: boolean= false;

  expandChange() {
    this.updateFlag++;
  }

  aboutToAppear() {
    Log.showInfo(TAG, `aboutToAppear Start`)
    if (CheckEmptyUtils.isEmpty(this.itemData?.largeIcon)) {
      this.hasPicture = false;
    } else {
      this.hasPicture = true;
    }
    this.needExpand = this.checkItemNeedExpand()
    ViewModel.getDistributedDeviceName(this.itemData).then((deviceName) => {
      this.distributedDeviceName = deviceName;
    })
  }

  checkItemNeedExpand() {
    if (this.itemData?.contentType === Constants.NOTIFICATION_TYPE_BASIC
    && (!(this.itemData?.actionButtons?.length > 0))) {
      return false;
    } else {
      return true;
    }
  }

  aboutToDisappear() {
    Log.showInfo(TAG, `aboutToDisappear`);
  }

  build() {
    Column() {
      titleItem({
        notificationSmallIcon: this.itemData?.smallIcon,
        notificationName: this.itemData?.appName,
        notificationTime: this.itemData?.time,
        isExpand: $isExpand,
        needExpand: this.needExpand,
        distributedDeviceName: this.distributedDeviceName,
        isSubItem: this.isSubItem,
        clickTitleAction: () => null
      })
      ContentComponent({
        isExpand: this.isExpand,
        itemData: this.itemData
      });

      if (this.isExpand && this.itemData?.actionButtons.length) {
        ActionComponent({ itemData: this.itemData })
      } else {
        Blank()
          .height(Layout.ITEM_MARGIN)
      }
    }.onClick(() => {
      this.clickAction();
    })
  }
}

@Component
struct ContentComponent {
  @Prop isExpand: boolean;
  itemData: NotificationItemData | undefined = undefined;

  aboutToAppear() {
    Log.showInfo(TAG, `aboutToDisappear`);
  }

  build() {
    Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
      Row() {
        if (this.itemData?.contentType === Constants.NOTIFICATION_TYPE_BASIC) {
          basicItem({
            itemData: this.itemData
          });
        }
        if (this.itemData?.contentType === Constants.NOTIFICATION_TYPE_LONG) {
          longItem({
            itemData: this.itemData,
            isExpand: this.isExpand
          });
        }
        if (this.itemData?.contentType === Constants.NOTIFICATION_TYPE_MULTILINE) {
          multiItem({
            itemData: this.itemData,
            isExpand: this.isExpand
          });
        }
        if (this.itemData?.contentType === Constants.NOTIFICATION_TYPE_PICTURE) {
          pictureItem({
            itemData: this.itemData,
            isExpand: this.isExpand
          });
        }
      }.flexGrow(1)

      if (this.itemData?.picture) {
        Image(this.itemData?.picture)
          .objectFit(ImageFit.Contain)
          .width(Layout.NOTIFICATION_PIC_SIZE)
          .height(Layout.NOTIFICATION_PIC_SIZE)
          .borderRadius($r("app.float.device_image_radius"))
      }
    }.margin({ left: Layout.ITEM_MARGIN, right: Layout.ITEM_MARGIN })
  }
}