#!/usr/bin/env python
import rospy
import math
import tf

if __name__ == "__main__":
    rospy.init_node("tf_based_on_ar_marker")
    parent_link = rospy.get_param("parent_link", "base_link")
    static_marker_link = rospy.get_param("static_marker_link", "ar_marker_link")
    ar_marker_link = rospy.get_param("ar_marker_link", "ar_marker_4")
    target_link = rospy.get_param("target_link", "head_camera")

    listener = tf.TransformListener()

    while not rospy.is_shutdown():
        try:
            t_ = listener.getLatestCommonTime(ar_marker_link, target_link)
            trans, rot = listener.lookupTransform(ar_marker_link, target_link, t_)
            t_ = listener.getLatestCommonTime(parent_link, static_marker_link)
            trans2, rot2 = listener.lookupTransform(static_marker_link, parent_link, t_)
            br = tf.TransformBroadcaster()
            br.sendTransform((trans[0]-trans2[0], trans[1]-trans2[1], trans[2]-trans2[2]),
                             tf.transformations.quaternion_from_euler(math.atan2(trans[2]-trans2[2],trans[0]-trans2[0]), math.atan2(trans[0]-trans2[0], trans[2]-trans2[2]), math.atan2(trans[1]-trans2[1],trans[0]-trans2[0])),
                             rospy.Time.now(),
                             "dummy_link",
                             parent_link)
            print trans
        except Exception as e:
            print e
            #continue